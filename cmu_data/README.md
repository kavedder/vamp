## Data files

The files in this directory were downloaded from the CMU-Arctic repository, a report on which can be found here: http://festvox.org/cmu_arctic/cmu_arctic_report.pdf

From this project, we are using recorded speech files (under wav) and labeled phoneme files (under lab). To obtain them, simply run the following in a terminal:

```bash
for person in awb bdl clb jmk ksp rms slt; do
    wget -r -np -k -nd -P $person "http://www.speech.cs.cmu.edu/cmu_arctic/packed/cmu_us_${person}_arctic-0.95-release.tar.bz2"
    tar jxf $person/cmu_us_${person}_arctic-0.95-release.tar.bz2
    rm -rfv $person
done
```
