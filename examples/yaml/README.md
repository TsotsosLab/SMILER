# YAML Experiment Example Files

Although users may directly use the CLI to conduct experiments and generate
saliency maps with SMILER, the CLI additionally supports experiment
specification using YAML. This is the recommended method of operation, as it
allows a user to maintain explicit records of experimental settings and
protocols through stored YAML specification files.

YAML is a data serialization language designed to be easily written, read, and
understood by humans. SMILER uses YAML files to specify experiments. These YAML
specification files are composed of two sections: an `experiment`, which
provides global specification details, and one or more experimental `runs`,
which provide details for a specific algorithm call.

```yaml
experiment:
  name: Simple Example
  description: An illustrative example of how to set up SMILER YAML experiments.
  input_path: /tmp/test_in
  base_output_path: /tmp/test_out
  parameters:
    do_smoothing: none

runs:
  - algorithm: AIM
    output_path: /tmp/AIM_smoothing
    parameters:
      do_smoothing: default

  - algorithm: AIM
    output_path: /tmp/AIM_no_smoothing

  - algorithm: DGII

  - algorithm: oSALICON
    parameters:
      color_space: LAB
```

Once you have your experiment described as a YAML file, you can run it with the
following command:

```
./smiler run -e experiment.yaml
```

The `name` and `description` fields are primarily for user records, and
facilitate organization and sharing of experimental protocols by providing a
lightweight document which can easily be created and stored for each experiment
conducted and run on any system with SMILER installed. `input_path` is the
folder which contains the images to be processed in this particular experiment.
`base_output_path` provides a root location for output maps to be saved, which
by default will be placed in a subfolder at this location named for the
algorithm that produced it (in the above example, DGII and oSALICON will be
saved in `/tmp/test_out/DGII` and `/tmp/test_out/oSALICON` respectively).

YAML specification introduces an additional layer to parameter precedence. The
`parameters` field within the `experiment` field provides a way to set
customized values which will be used for all runs, but these may be overridden
for a specific run by adding a `parameters` field to that run. In the above
example, all runs are set to be performed without smoothing based on the
parameter specification under the `experiment` field, but the first run using
AIM overrides this specification and instead uses default smoothing parameters.
In this case, both AIM runs are include `output_path` fields which will override
the default behaviour using `base_output_path`. In the provided example, DGII
will be run without any additional specifications beyond those provided in the
`experiment` field, while oSALICON will be run with an additional specification
of the `color_space` parameter (since there is no `color_space` specification
under `experiment`, all other runs will use the built-in SMILER default: RGB).
