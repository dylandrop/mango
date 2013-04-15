#include "Bleep.h"

void BleepMachine::queueCallback( AudioQueueRef outAQ, AudioQueueBufferRef outBuffer )
{
    // Render the wave
    
    // AudioQueueBufferRef is considered "opaque", but it's a reference to
    // an AudioQueueBuffer which is not. 
    // All the samples manipulate this, so I'm not quite sure what they mean by opaque
    // saying....
    SInt16* coreAudioBuffer = (SInt16*)outBuffer->mAudioData;
    
    // Specify how many bytes we're providing
    outBuffer->mAudioDataByteSize = kBufferSizeInFrames * m_outFormat.mBytesPerFrame;
    
    // Generate the sine waves to Signed 16-Bit Stero interleaved ( Little Endian )
    float volumeL = m_waves[kLeftWave].volume;
    float volumeR = m_waves[kRightWave].volume;
    float phaseL = m_waves[kLeftWave].phase;
    float phaseR = m_waves[kRightWave].phase;
    float fStepL = m_waves[kLeftWave].fStep;
    float fStepR = m_waves[kRightWave].fStep;
    
    for( int s=0; s<kBufferSizeInFrames*2; s+=2 )
    {
        float sampleL = ( volumeL * sinf( phaseL ) );
        float sampleR = ( volumeR * sinf( phaseR ) );
        
        short sampleIL = (int)(sampleL * 32767.0);
        short sampleIR = (int)(sampleR * 32767.0);
        
        coreAudioBuffer[s] =   sampleIL;
        coreAudioBuffer[s+1] = sampleIR;
        
        phaseL += fStepL;
        phaseR += fStepR;

    }
    /*
    Wave& wave = m_waves[0];
    Wave& wave2 = m_waves[1];
    
    if (wave.volume > 0.01)
        wave.volume -= 0.01;
    if (wave2.volume > 0.01)
        wave2.volume -= 0.01;
    */
    m_waves[kLeftWave].phase = fmodf( phaseL, 2 * M_PI );   // Take modulus to preserve precision
    m_waves[kRightWave].phase = fmodf( phaseR, 2 * M_PI );
    
    // Enqueue the buffer
    AudioQueueEnqueueBuffer( m_outAQ, outBuffer, 0, NULL ); 
}

bool BleepMachine::SetWave( int id, float frequency, float volume )
{
    if ( ( id < kLeftWave ) || ( id >= kNumWaves ) ) return false;
    
    Wave& wave = m_waves[ id ];
    
    wave.volume = volume;
    wave.frequency = frequency;
    wave.fStep = 2 * M_PI * frequency / kSampleRate;
    
    return true;
}

bool BleepMachine::Initialise()
{
    m_outFormat.mSampleRate = kSampleRate;
    m_outFormat.mFormatID = kAudioFormatLinearPCM;
    m_outFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    m_outFormat.mFramesPerPacket = 1;
    m_outFormat.mChannelsPerFrame = 2;
    m_outFormat.mBytesPerPacket = m_outFormat.mBytesPerFrame = sizeof(UInt16) * 2;
    m_outFormat.mBitsPerChannel = 16;
    m_outFormat.mReserved = 0;
    
    OSStatus result = AudioQueueNewOutput(
                                          &m_outFormat,
                                          BleepMachine::staticQueueCallback,
                                          this,
                                          NULL,
                                          NULL,
                                          0,
                                          &m_outAQ
                                          );
    
    if ( result < 0 )
    {
        printf( "ERROR: %d\n", (int)result );
        return false;
    }
    
    // Allocate buffers for the audio
    UInt32 bufferSizeBytes = kBufferSizeInFrames * m_outFormat.mBytesPerFrame;
    
    for ( int buf=0; buf<kNumBuffers; buf++ ) 
    {
        OSStatus result = AudioQueueAllocateBuffer( m_outAQ, bufferSizeBytes, &m_buffers[ buf ] );
        if ( result )
        {
            printf( "ERROR: %d\n", (int)result );
            return false;
        }
        
        // Prime the buffers
        queueCallback( m_outAQ, m_buffers[ buf ] );
    }
    
    m_isInitialised = true;
    return true;
}

void BleepMachine::Shutdown()
{
    Stop();
    
    if ( m_outAQ )
    {
        // AudioQueueDispose also chucks any audio buffers it has
        AudioQueueDispose( m_outAQ, true );
    }
    
    m_isInitialised = false;
}

BleepMachine::BleepMachine()
: m_isInitialised(false), m_outAQ(0)
{
    for ( int buf=0; buf<kNumBuffers; buf++ ) 
    {
        m_buffers[ buf ] = NULL;
    }
}

BleepMachine::~BleepMachine()
{
    Shutdown();
}

bool BleepMachine::Start()
{
    OSStatus result = AudioQueueSetParameter( m_outAQ, kAudioQueueParam_Volume, 1.0 );
    if ( result ) printf( "ERROR: %d\n", (int)result );
    
    // Start the queue
    result = AudioQueueStart( m_outAQ, NULL );
    if ( result ) printf( "ERROR: %d\n", (int)result );
    
    return true;
}

bool BleepMachine::Stop()
{
    OSStatus result = AudioQueueStop( m_outAQ, true );
    if ( result ) printf( "ERROR: %d\n", (int)result );
    
    return true;
}

// A    (A4=440)
// A#   f(n)=2^(n/12) * r
// B    where n = number of semitones
// C    and r is the root frequency e.g. 440
// C#
// D    frq -> MIDI note number
// D#   p = 69 + 12 x log2(f/440)
// E
// F    
// F#
// G
// G#
//
// MIDI Note ref: http://www.phys.unsw.edu.au/jw/notes.html
//
// MIDI Node numbers:
// A3   57
// A#3  58
// B3   59
// C4   60 <--
// C#4  61
// D4   62
// D#4  63
// E4   64
// F4   65
// F#4  66
// G4   67
// G#4  68
// A4   69 <--
// A#4  70
// B4   71
// C5   72

float CalculateFrequencyFromNote( SInt32 semiTones, SInt32 octave )
{
    semiTones += ( 12 * (octave-4) );
    float root = 440.f;
    float fn = powf( 2.f, (float)semiTones/12.f ) * root;
    return fn;
}

float CalculateFrequencyFromMIDINote( SInt32 midiNoteNumber )
{
    SInt32 semiTones = midiNoteNumber - 69;
    return CalculateFrequencyFromNote( semiTones, 4 );
}
