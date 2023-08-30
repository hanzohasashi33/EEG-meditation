import os 
import sys
import glob
import numpy as np
import pandas as pd 
import mne
import matplotlib
matplotlib.use('Qt5Agg')

pathToSave = ""

variableNames = ["FP1", "FP2", "F7", "F3", "Fz", "F4", "F8", "T3", "C3", "Cz", "C4", "T4", "T5", "P3", "PZ", "P4", "T6", "O1", "O2", "A1", "A2", "SensorCEOG", "SensorDEOG"]
variableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"]


eegFiles = glob.glob("C:/Users/PRASANNA/Desktop/sem9/eeg_project/eegdatafiles/*.txt")
# eegFiles = glob.glob("/mnt/c/Users/PRASANNA/Desktop/sem9/eeg_project/eegdatafiles/*.txt")

# load list of all files in folder
# print(eegFiles)


# create empty variables to be filled later
rejected_componentandtype = np.zeros((len(eegFiles), 1))
answer = np.zeros((len(eegFiles), 1))
confidence = np.zeros((len(eegFiles), 1))
sleepiness = np.zeros((len(eegFiles), 1))
focus = np.zeros((len(eegFiles), 1))
sensation = np.zeros((len(eegFiles), 1))
engagement = np.zeros((len(eegFiles), 1))
visual = np.zeros((len(eegFiles), 1))
auditory = np.zeros((len(eegFiles), 1))
flat_channels = np.zeros((len(eegFiles), 1))
noisy_channels = np.zeros((len(eegFiles), 1))


sfreq = 256
info = mne.create_info(ch_names=variableNames, sfreq=sfreq)


raw = pd.read_csv(eegFiles[1],skiprows=0,encoding='latin1')
raw.columns = ["FP1", "FP2", "F7", "F3", "Fz", "F4", "F8", "T3", "C3", "Cz", "C4", "T4", "T5", "P3", "PZ", "P4", "T6", "O1", "O2", "A1", "A2", "SensorCEOG", "SensorDEOG", "Events"]
# print(data)
# print(data.columns)


# get the trigger names and times if any
# trig = data["Events"]
# trig_names = trig[~np.isnan(trig)]
# print(trig_names)

# exclude events column from the dataframe
raw = raw.drop(["Events"], axis=1)

# get rid of nans if any (normally the last samples)
raw = raw.dropna()

print(raw.shape)

raw = mne.io.RawArray(raw.T, info)
low_freq, high_freq = 1.0, 40.0 # values in Hz
# mneData = mneData.filter(low_freq, high_freq, picks=["FP1", "FP2", "F7", "F3", "Fz", "F4", "F8", "T3", "C3", "Cz", "C4", "T4", "T5", "P3", "PZ", "P4", "T6", "O1", "O2", "A1", "A2"])
raw.plot(block=True)