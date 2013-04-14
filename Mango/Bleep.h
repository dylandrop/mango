//
//  BleepMachine.h
//  WgHeroPrototype
//
//  Created by Andy Buchanan on 05/01/2010.
//  Copyright 2010 Andy Buchanan. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>

// Class to implement sound playback using the AudioQueue API's
// Currently just supports playing two sine wave tones, one per
// stereo channel. The sound data is liitle-endian signed 16-bit @ 44.1KHz
//
class BleepMachine
{
    static void staticQueueCallback( void* userData, AudioQueueRef outAQ, AudioQueueBufferRef outBuffer )
    {
        BleepMachine* pThis = reinterpret_cast<BleepMachine*> ( userData );
        pThis->queueCallback( outAQ, outBuffer );
    }
    void queueCallback( AudioQueueRef outAQ, AudioQueueBufferRef outBuffer );
    
    AudioStreamBasicDescription m_outFormat;
    
    AudioQueueRef m_outAQ;
    
    enum 
    {
        kBufferSizeInFrames = 512,
        kNumBuffers = 4,
        kSampleRate = 44100,
    };
    
    AudioQueueBufferRef m_buffers[kNumBuffers];
    
    bool m_isInitialised;
    
    struct Wave 
    {
        Wave(): volume(1.f), phase(0.f), frequency(0.f), fStep(0.f) {}
        float   volume;
        float   phase;
        float   frequency;
        float   fStep;
    };
    
    enum 
    {
        kLeftWave = 0,
        kRightWave = 1,
        kNumWaves,
    };
    
    Wave m_waves[kNumWaves];
    
public:
    BleepMachine();
    ~BleepMachine();
    
    bool Initialise();
    void Shutdown();
    
    bool Start();
    bool Stop();
    
    bool SetWave( int id, float frequency, float volume );
};

// Notes by name. Integer value is number of semitones above A.
enum Note
{
    A       = 0,
    Asharp,
    B,
    C,
    Csharp,
    D,
    Dsharp,
    E,
    F,
    Fsharp,
    G,
    Gsharp,
    
    Bflat = Asharp,
    Dflat = Csharp,
    Eflat = Dsharp,
    Gflat = Fsharp,
    Aflat = Gsharp,
};

// Helper function calculates fundamental frequency for a given note
float CalculateFrequencyFromNote( SInt32 semiTones, SInt32 octave=4 );
float CalculateFrequencyFromMIDINote( SInt32 midiNoteNumber );