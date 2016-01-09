# chaoticScan



Steps of the procedure
Consider the Image as an Elementary Cellular Automaton
Vector of Image length with random Initial Conditions
Apply the Wolfram Rule 101 to all cells
Divide to sets of n cells
n is the binary of log2(total pixels)
XOR with mask of n length
Get the address and change the value of the cell
Repeat to reach the desired compression ratio



R. Dogaru, I. Dogaru, H. Kim. Chaotic Scan: A Low Complexity Video Transmission System for Efficiently Sending Relevant Image Features, in IEEE Trans. on Circuits and Systems for Video Technology, Vol.20, pp. 317-321, February 2010.
