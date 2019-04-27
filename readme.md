# 2019 - Computer Vision Coursework

## Running the tasks

### Facial Recognition

1. Download the models from [google drive](https://drive.google.com/open?id=18c_Qi0Zg7BUoXI_SmHbRjq7hLVRXdDkr)
2. Place the downloaded files in the `'./models`  subfolder
3. Call `RecognizeFace(I, featureType, classifier)`
   1. Accepted feature types: `'SURF'`, `'HOG'`
   2. Accepted classification methods: `'NB'`, `'KNN'`, `'SVM'`, `'RF'`, `'CNN'`
   **Note:** If classification method is `'CNN'`, the feature type is disregarded, but some data still needs to be passed.
4. Function should return a numerical matrix, the first column represents the predicted label, the second column represents the x coordinate of the central facial region, and the third column represents the y coordinate of the central facial region. If no faces are found in the image, it returns an empty array instead `[]`.
5. For further reference, see `test_recognizeFace.m` for a sample on how to call the script

### Digit/Label Detection

1. Call `detectNum(filepath)`
2. Returned value should be a numerical array containing all the numbers/labels detected in the media referenced by `filepath`
3. Accepted file extensions are: `.jpg`, `.jpeg`, `.mp4`, `.mov`
**Note:** The `detectNum` function is able to detect more than one number in an image. Also, if no numbers are found in the image, it returns an empty array `[]`.

### General structure

- `RecognizeFace.m`: Function that detects and predicts labels according to multiple previously trained classifiers.
- `detectNum.m`: Function that detects numerical labels in the media file passed as parameter.
- `ExtractNumbersFromFrame.m`: Function that performs the actual number detection within a given image. `detectNum.m` acts more as a wrapper for control flow.
- `test_recognizeFace.m`: Script used for testing `RecognizeFace.m`. Can be used as reference material.
- `test_detectNum.m`: Script used for testing `detectNum.m`. Can be used as reference material.
- `./scripts/`: Folder containing scripts and functions used both for running the assigned tasks and for the preprocessing pipeline.
- `./results/`: Folder containing results for the multiple classifiers trained.
- `./models/`: Folder containing the saved models for each classifier trained. Data should be downloaded from [google drive](https://drive.google.com/open?id=18c_Qi0Zg7BUoXI_SmHbRjq7hLVRXdDkr) as files were too large to be submitted via Moodle.
- `report.pdf`: Written report containing further explanations regarding the work done.
