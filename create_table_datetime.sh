#!bash/file

#creates a list with all the image names, removes letters and points and convert this to a document.
ls *tif | tr -d "[:alpha:]" | tr -d "." > filenames.txt

#Creates a document with a header that contains imagenumbers and the date and time of all the images.
echo "image_number timestamp" > tables/datetime_table.txt

#extracts the imagenumbers, dates and times from the list with the imagenames and adds this to the document
#that contains the header.
awk -F "_" '{print $5, $6}' filenames.txt >> tables/datetime_table.txt

#remove the absolete filenames.txt
rm filenames.txt
