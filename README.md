# SequenceSender
A library for AutoHotkey to make it easy to send (optionally repeating) sequences of characters

## Objectives
The purpose of this library is to allow users to easily send sequences of characters, with timing (eg waiting between keys)  
* All "Asynchronous" code. No loops  
This is to minimize interference with your other code. AHK is not a multi-threaded language!    
* When stopping, can abort mid-sequence  
Saves you checking between each send or sleep if we want to stop  
* Supports Random sleep times  
Give it a min and max amount of time to sleep, and it will pick a random value  
* Specify what to send using identical syntax to AHK's `Send` command, with extra "Tokens" to handle Sleeping etc  

## Usage
### Overview
1. Include the library: `#include SequenceSender.ahk`  
1. Create a new SequenceSender object: `ss := new SequenceSender()`  
1. Optionally set options, eg `ss.ResetOnStart(false)`
1. Load a SequenceString: `ss.Load("^a^c!{Tab}^v")`  
1. Start using `ss.Start()`, stop using `ss.Stop()`  

### SequenceStrings
A SequenceString is a string of text which describes to SequenceSender what needs to be sent and the timings that need to be used  
SendStrings can comprise of two types of text:  
1. SendString  
This tells SequenceSender to send some keys.  
    1. It is in normal AHK `Send` format, eg `^a` or `^{a}` to send Ctrl-A  
    1. When sending, any modifiers plus **one** key are sent at a time  
      eg A SendString of `^a^{b}ccc` will send in 5 chunks: `^a`, `^{b}` `c`, `c`, `c`
1. TokenString  
This tells SequenceSender to take a special action
    1. It is wrapped in the Token Delimiters (`[` and `]` by default)  
    1. Delimiters can be changed  
    1. Example token: `[Sleep 100]` to sleep for 100ms  

A SequenceString may comprise of any number of SendStrings and TokenStrings  
eg `^a[Sleep 100]^c` to send Ctrl-A, wait 100ms, then send Ctrl-C  

### SequenceSender object Method Reference
Once you have created a new SequenceSender object (eg using `ss := new SequenceSender()`), then the following functions are available for you to use:  

#### Option Setting Methods  
##### Repeat
`Repeat(<true/false>)`  
eg `ss.Repeat(true)`  
Sets whether or not the sequence repeats once it gets to the end  
Default is `True`  
**Note that one of `Repeat` or `ResetOnStart` must be set to True**  

##### ResetOnStart
`ResetOnStart(<true/false>)`  
eg `ss.ResetOnStart(false)`  
Sets whether or not the sequence resumes from the start (True) or where it left off (False) when you call `Start()`  
Default is `True`  
**Note that one of `Repeat` or `ResetOnStart` must be set to True**  

##### SetTokenChars
`SetTokenChars(<open>, <close>)`  
eg `ss.SetTokenChars("(", ")")`  
Sets the characters used to open and close TokenStrings  
Defaults to `[` and `]`  

##### Debug
`Debug(<true/false>)`  
eg `ss.Debug(true)`  
Sets Debug Mode on  
In Debug Mode, no characters will be sent - instead they will be logged out to the debug stream  
Use SCiTE4AutoHotkey or DebugView to view the debug output.  
Defaults to `False`  

##### BlindMode
`BlindMode(<true/false>)`  
eg `ss.BlindMode(true)`  
Enables or Disables the `{Blind}` prefix for Sends  
Defaults to `False`  

#### Other Methods  
##### Start
`Start()`  
eg `ss.Start()`  
Starts sending  

##### Stop()
`Stop()`  
eg `ss.Stop()`  
Stops sending  

#### Chaining  
All Methods can be "chained".  
for example, to create the SequenceSender object, load a SequenceString, set some options, and start - all on one line of code, you could do:  
`ss := new SequenceSender().Repeat(false).Load("^a^c").Start()`  
With AHK "continuation sections", this can also be split across multiple lines - just make sure each new line begins with `.`:  
```
ss := new SequenceSender()
    .Repeat(false)
    .Load("^a^c")
    .Start()
```
