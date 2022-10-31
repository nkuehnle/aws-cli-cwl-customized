cwlVersion: v1.2
class: ExpressionTool
requirements:
  InlineJavascriptRequirement: {}

inputs:
  infiles:
    type:
      type: array
      items:
        type: array
        items: File

outputs:
  files: File[]

expression: |
  ${
  var files = [];
  for (var n = 0; n < inputs.infiles.length; n++) {
    for (var i = 0; i < inputs.infiles[n].length; i++) {
      files.push(inputs.infiles[n][i]);
    }
  }
  return {"files": files};
  }
