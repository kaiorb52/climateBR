
## R CMD check results ────── climateBR 0.2.0 ────

Duration: 54.3s

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✖

R CMD check succeeded

* This is a resubmission.

Changes in this version include:

- Fixed bugs related to downloading and building the INMET database.
- Added the `nearest_stations()` function.
- Updated and simplified the package datasets.
- Added new `years` and `partitioning_by` arguments to `build_inmet_dataset()`.

`R CMD check` was run successfully with 0 errors and 0 warnings. The only NOTE is related to the inability to verify the current time.
