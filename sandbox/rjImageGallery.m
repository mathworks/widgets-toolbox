%% Create the image gallery
f = uifigure;
g = uigridlayout(f,[1,1]);
w = ImageGallery(g,'BackgroundColor','green')


%% Show some images from MATLAB
searchRoot = fullfile(matlabroot,'toolbox','images','imdata');
fileInfo = dir( fullfile(searchRoot,"*.png") );
fileNames = sortrows( string({fileInfo.name}') );
filePaths = fullfile(searchRoot, fileNames);
w.ImageSource = filePaths;


%% Big images
searchRoot = "C:\Users\rjackey\OneDrive - MathWorks\Pictures\2011-10-31 Argentina\";
fileInfo = dir( fullfile(searchRoot,"*.jpg") );
fileNames = sortrows( string({fileInfo.name}') );
filePaths = fullfile(searchRoot, fileNames);
w.ImageSource = filePaths;
