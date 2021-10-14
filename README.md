# String-Primatives-Macro-assembly

Portfolio project for CS 271 OSU

This project does the following:

1. mplement and test two macros for string processing. These macros may use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.
   > mGetString: Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.
   > mDisplayString: Print the string which is stored in a specified memory location (input parameter, by reference).
2. Implement and test two procedures for signed integers which use string primitive instructions
   > ReadVal: Invoke the mGetString macro (see parameter requirements above) to get user input in the form of a string of digits. Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc). Store this value in a memory variable (output parameter, by reference).
   > WriteVal: Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits
   > Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.
3. Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:
   > Get 10 valid integers from the user.
   > Stores these numeric values in an array.
   > Display the integers, their sum, and their average.

Assembly x86 was used
