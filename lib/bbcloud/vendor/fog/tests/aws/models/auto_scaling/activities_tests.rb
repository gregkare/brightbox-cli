Shindo.tests('AWS::AutoScaling | activities', ['aws', 'auto_scaling_m']) do

  pending # FIXME: activity#save is not implemented
  collection_tests(AWS[:auto_scaling].activities, {}, false)

end
