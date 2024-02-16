class: Workflow
cwlVersion: v1.2

doc: |
  This is a CWL workflow (with Arvados specific enhancements) to
  perform bulk upload of a list of files to a S3 bucket.

  It spreads the load across the desired number of parallel downloads by
  splitting up the list and giving each compute node a list of files to
  download.

  Note: it divides the list ahead of time by round-robin assigning each
  entry in `files` to a batch, so if there is a big disparity in object
  sizes, some jobs might finish before the others.

  This workflow has no output besides success or failure status.

$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

hints:
  cwltool:Secrets:
    secrets: [aws_access_key_id, aws_secret_access_key]

inputs:
  files:
    type: File[]
    label: "List of File objects to upload"
  s3target:
    type: string
    label: "The target s3:// URL to upload to."
    doc: |
      This is a string prefix to which the file name is appended
      so you usually want a trailing slash.
  parallel_transfers:
    type: int
    default: 1
    label: "Number of downloader processes to use"
  aws_access_key_id:
    type: string
    label: "AWS access key id"
  aws_secret_access_key:
    type: string
    label: "AWS secret access key"
  endpoint:
    type: string?
    label: "URL to use if contacting a custom S3 API endpoint"

steps:
  split:
    in:
      urls: files
      count: parallel_transfers
    run: tools/batch.cwl
    out: [batches]

  upload-batch:
    in:
      files: split/batches
      s3target: s3target
      aws_access_key_id: aws_access_key_id
      aws_secret_access_key: aws_secret_access_key
      endpoint: endpoint
    scatter: files
    run: tools/aws-s3-upload.cwl
    out: []

outputs: []
