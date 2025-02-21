cwlVersion: v1.2
class: ExpressionTool
requirements:
  InlineJavascriptRequirement: {}
inputs:
  urls:
      - type: array
        items: [string, File]
  count: int
outputs:
  batches:
    type:
      - type: array
        items:
          type: array
          items: [string, File]

expression: |
  ${
  var batches = [];
  for (var i = 0; i < inputs.count; i++) {
    batches.push([]);
  }
  for (var n = 0; n < inputs.urls.length; n++) {
    batches[n % inputs.count].push(inputs.urls[n]);
  }
  return {"batches": batches};
  }
