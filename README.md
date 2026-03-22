# jPCA for Aplysia neural recordings

jPCA original code can be found on Mark Churchland's website 

## Note 
This code was tested on Matlab 2023b and 2024b.

# How to use
1. Download the code from this repository
2. Unzip the folder and open the file `Comparing_jPCAs.m` in Matlab
3. In Matlab, navigate to the folder where the neural recordings are stored
4. Press Run. When prompted, press **"Add to Path"**
5. Choose the name of the file to be analysed 
```Matlab
filename = 'Feb0416_1.mat';
```
8. Define the segments to be analysed
```Matlab
% Define as many segments as you want (Nx2 matrix)
% Every row defines a new segment in which the first and second columns are the start 
% and end time, respectively.
% values are in seconds from the start of the recording 
segments = [
    90,250;
    300,900;
    % add more rows here
];

```
10. Results should appear!
