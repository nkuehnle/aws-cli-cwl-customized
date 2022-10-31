aws-s3-bulk-cp.cwl

This is a CWL workflow (with Arvados specific enhancements) to
perform bulk download of a list of S3 objects.

It spreads the load across the desired number of parallel downloads by
splitting up the list and giving each compute node a list of files to
download.

Note: it divides the list ahead of time by round-robin assigning each
entry in s3urls to a batch, so if there is a big disparity in object
sizes, some jobs might finish before the others.

Files are merged to get one big final output collection.  Assumes
there are no filename conflicts.


Here is what the input.yml file should look like:

# List of s3:// URLs of objects to download
s3urls:
  - s3://bucket/object1
  - s3://bucket/object2
  - s3://bucket/object3

# Number of downloader processes to use
parallel_downloads: 3

# AWS credentials, these are marked as secret inputs
# so they will not be exposed by Arvados
aws_access_key_id:  <access key>
aws_secret_access_key: <secret key>
