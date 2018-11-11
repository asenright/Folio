<h1>Pipelined Processor Design</h1>
<h2>About</h2>
This is the design for a very simple, pipelined processor. Its instruction set could be described as similar to MIPS, but for licensing reasons, it has its own proprietary instruction set described further in the documentation. To simulate and run it, you need Verilog simulation software (i.e. Synopsis).

<h2>Prerequisites</h2>
The Verilog code given here must be run on a Verilog-compatible simulator, such as Synopsis.

<h2>What's In It</h2>
The processor is broken into modules; each has its own testbench. For example, to test programcounter.v, you would compile and run programcounter_fixture.v
For more info about the instruction set, see the documentation .pdf.

<h2>Authors</h2>
Andrew Enright and Ethan Kinyon

<h2>License</h2>
This project is licensed under the MIT License - see the LICENSE.md file for details

<h2>Acknowledgments</h2>
This project was written as an assignment for CSU Sacramento's CPE142 class. The instruction set is owned by Dr. Behnam Arad at CSU Sacramento.
