# curEM: match-to-sample task EEG & ETanalysis, visit 1


To replicate the findings of the paper 'I err, therefore I am: Neural
signature of error-monitoring predicts self-awareness in infants':


First run the EEG scripts:

1: curE_EEG_1_get_matfiles_from_mff.m

    - for erpType = 'ERN'
    
    - then for erpType = 'FRN'
    
2: curE_EEG_2a_select_included_data.m

    - for erpType = 'ERN'
    
    - then for erpType = 'FRN'
    
   Then curE_EEG_2b_OPTIONAL_select_common_included_data.m
   for erpType = ['ERN' 'FRN']
   
3: curE_EEG_3_processing_exporting.m

    - for erpType = 'ERN'
    
    - then for erpType = 'FRN'
    
4: curE_EEG_4_plotting.m

    - for erpType = 'ERN'
    
    - then for erpType = 'FRN'

Then run the ET scripts:

1: curE_ET_1_ImportingDataIntoMatlab.m

2: curE_ET_2_ParseFixations.m

3: curE_ET_3_Plotting.m


/!\ Respect the order of the scripts and the erpTypes:
    - ERN baseline values are needed for FRN processing,
    - FRN included trials are needed for ERN processing,
    - EEG values are needed for adequate file export for running stats.


The scripts output files in multiple folders.
Use the csv files in this folder to conduct the statistical analyses:
/Users/[yourusername]/Data/curE/Visit1/eyetracking copy/4_OutputsForStats


JASP files pointing to the csv files outputted are provided for running
statistical analyses.



The data is sensitive & thus not provided here, please get in touch with
the authors if you require access to the data. Data sharing might not
always be possible depending on Danish & EU regulations.



NOTE: some of the scripts can be ran without using parallel processing;
most of the ET scripts require Matlab's parallel processing toolbox and a
computer with at least 6 cores. 
