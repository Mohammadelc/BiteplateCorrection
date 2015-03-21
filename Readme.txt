Use BPRotation.m to generate bite-plate correction parameters file first for each subject 

Use BiteplateCorrect.m to run the bite-plate correction by given the tsv file and associate bite-plate parameter file.

Use BiteplateCorrect.m to check the sensors' position by setting 'flag = 1' 


The suggested process of bite plate correction for each subject:

Example: eager01

1. Run the BPRotation('eager01_biteplate.tsv') to generate bite-plate correction parameters

2. Run the BiteplateCorrection('eager01_biteplate.tsv',eager01_BPInfo.mat', 1, offset) to do the correction for bite plate record and check sensors position

   If the output message shows 'Pass: all sensors positions are in the correct configuation', then the bite plate correction can be applied to all the other files for this subject
   If the output is error message: check sensors channel and position according to the error.

3. Run the BiteplateCorrection('eager01_**.tsv', eager01_BPInfo.mat', 0, offset) for the other records of this subject











