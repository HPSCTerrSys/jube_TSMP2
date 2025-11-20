# jube_TSMP2
This `JUBE` file installs [TSMP2](https://github.com/HPSCTerrSys/TSMP2) and runs the test case from [TSMP2_workflow-engine](https://github.com/HPSCTerrSys/TSMP2_workflow-engine). The `JUBE` file also compare the results with a reference.

### For developing use
You must explicitly change the parameter `userInfo` and `bin_storage` in Lines 45-46:
```
  - name: userInfo
    parameter:
      - {name: branch_name, _: master}
      - {name: bin_storage, _: "/p/project1/cslts/shared_data/CI_TSMP2/bin"}
```
For this example, the jube file is using the master-branch and the binaries of build will be saved in the cslts_project folder.
The complete path to the saved binaries is:
```
${bin_storage}/${branch_name}/${system_name}_${model_id}_${env_str}
```


### How to use it
If the working directory to the benchmark is:
```
working_dir = path_to_benchmark_folder/benchmark/jube
```

1) Upload JUBE:
```
ml JUBE
```

2) Run JUBE:

In the `working_dir` that contains the “jube_filename.yml” file, submit the following command, replacing the tags (see section Tags below):
```
jube -v run --tag system_tag execution_mode_tag download_data_tag tsmp_combination_tag(s) environment_tag --outpath ./outpath -r -e jube_filename.yml
```
##### NOTE: Tags must be provided after `--tag` (in any order).

`-v` is verbose, displays the log-output during the run

`-e` jube run will exit if there is an error

`-r` run result after finishing run command (this will also start analysis)

`--outpath` defines where the benchmark is going to be stored

For more details on how to run JUBE, have a look at the JUBE [documentation](https://apps.fz-juelich.de/jsc/jube/docu/commandline.html).

3) Continue an existing benchmark (after running the simulation is finished):
```
jube continue ./outpath -r -e
```

After step (3), JUBE will produce a results table. For instance:
```
system,version,queue,account,variant,components,jobid,nodes,ntasks,taskspernode,threadspertask,runtime_sec,runtime,success,comparison_eclm
jurecadc,2024.01,dc-cpu,slts,single,eCLM,14230309,1,128,128,128,85,00:01:25,true,SUCCESSFUL
```

### Tags

`system_name`: machine where the benchmark runs.

`execution_mode`: allows to choose among `full` (build + run), `build` (only build), and `run` (only run). If no execution mode is defined, it will *only build*. To be able to use the `run` mode, the combination build must have been built previously. 
                  The builts are saved here `${bin_storage}=/path_to_binaries/bin/`. The built is saved as `<machine_components_environment>`, for instance `JURECADC_ICON-eCLM_jsc.2025.intel.psmpi`.

`download_data`: allows to choose between `data` (downloads data) and `nodata` (no data is downloaded). The data downloaded is the data needed to run the EUR-11 case. Data is available [here](https://datapub.fz-juelich.de/slts/tsmp_testcases/data/tsmp2_eur11_wfe_iniforc/). 
                 If no download data mode is defined, the data will not be downloaded. To use the `nodata` mode, data must have been downloaded previously, otherwise it the simulation run will fail.

`TSMP_components`: allows to choose the components for the build. Components: `icon`, `eclm`, `parflow`. If no component-combination is specified, it will build by default `eclm`.

`environment`: allows to choose among several defined environments. When no environment is spcified, it will use `jsc.2025.intel.psmpi`.


| Tag Name         | Tag Options                                                                 | Default Tag                            | Type of Tag                             |
|------------------|-----------------------------------------------------------------------------|----------------------------------------|-----------------------------------------|
| system_name      | jureca, juwels, jupiter, jusuf                                              | no default option, needs to be defined | exclusive (only one can be selected)    |
| execution_mode   | full, build, run                                                            | build                                  | exclusive (only one can be selected)    |
| download_data    | data, nodata                                                                | nodata                                 | exclusive (only one can be selected)    |
| TSMP_components  | icon, eclm, parflow                                                         | eclm                                   | multiple choices allowed                |
| environment      | jsc.2025.intel.psmpi  <br> jsc.2025.gnu.openmpi  <br> jsc.2025.gnu.psmpi  <br> jsc.2024.intel.psmpi <br> jsc.2023.intel.psmpi <br> default.2025.env <br> ubuntu.gnu.openmpi <br> uni-bonn.gnu.openmpi | jsc.2025.intel.psmpi       | exclusive (only one can be selected)     |


### Examples of jube commands
1) To build and run TSMP2 with `icon` + `eclm` on `jureca` using the environment `jsc.2025.gnu.openmpi`, the jube command would be:
```
jube -v run -r -e --tag jureca full icon eclm jsc.2025.gnu.openmpi --outpath ./outpath jube_filename.yml
```
Since no `download_data` is defined, it will NOT download the data (since it uses the default option).

2) To only build a fully-coupled TSMP2 (`icon + eclm + parflow`) on `juwels` using the environment `jsc.2025.intel.psmpi` and no download data, the jube command would be:
```
jube -v run -r -e --tag juwels build icon eclm parflow nodata jsc.2025.intel.psmpi --outpath ./outpath jube_filename.yml
```

3) If only the system name is provided (e.g., `juwels`):
```
jube -v run -r -e --tag juwels --outpath ./outpath jube_filename.yml
```   
It will use the default options on `juwels`: build, eclm, `jsc.2025.intel.psmpi`, and won't download data.


### Comparison of results
Reference case was produced on `jureca` using the `jsc.2025.intel.psmpi`. Reference results are here:
```
/p/project1/cslts/shared_data/rcmod_TSMP2_WFE_reference_CORDEX_JURECADC/simres/${model_id_sim}_20170701/
```

Scripts used to compare the outputs from `eclm`, `parflow`, and `icon` use a **threshold of 1E-8** and are stored here:
```
working_dir/../../usecompare/
```

```
usecompare]$ tree
.
├── compare_nc_eclm.sh
├── compare_nc_icon.sh
└── compare_nc_parflow.sh
```
Threshold can easily be modified on their respective scripts, as well as, the output variables to read.

- eclm compares the following variables of the output `eCLM_eur-11u.clm2.h0.2017-07-01-00000.nc`:
```
VARS=("TWS" "H2OSOI" "TSOI" "TG" "EFLX_LH_TOT" "FSH" "FSA" "FSR" "FIRA" "Rnet" "EFLX_SOIL_GRND")
```

- parflow compares the following variables of the output `eur-11u.out.00001.nc`:
```
VARS=("pressure" "saturation" "evaptrans")
```

- icon compares the following variables of the output `ICON_out_EU-R13B5_inst_DOM01_ML_20170702T000000Z_1h.nc`:
```
VARS=("w" "theta_v" "qv" "shfl_s" "lhfl_s")
```
There are three possible outputs of the comparison:
- SUCCESSFUL: variables' differences are below the threshold.
- FAILED: differences are greater than the threshold.
- MISSING-NC-FILES: reference and/or test output files are missing.

### Directories
- Results of the benchmark will be stored at `outpath`:
```
working_dir/outpath
```

- Builds will take place here:
```
working_dir/outpath/0000##/000001_build/work/TSMP2/bin/
```
Where `##` stands for the benchmark ID-number. For instance, `000000` or `000005`.

- Copy of binaries. When a build is carried out, as mentioned above, a copy of the binaries will be stored (to be used later) here:
```
/p/project1/cslts/shared_data/CI_TSMP2/bin/
```

- Runs will take place here:
```
working_dir/outpath/0000##/000003_execute/work/TSMP2_workflow-engine/run
```

- Comparison results (as a csv file) will be here:
```
working_dir/outpath/0000##/000005_compare/work/
```

- Results table will be saved here:
```
working_dir/outpath/0000##/result
```

-	Data will be downloaded here:
```
working_dir/download_data
```
