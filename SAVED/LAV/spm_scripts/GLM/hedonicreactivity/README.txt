


GLM-03: parametric modulators only on ANTs no classifier for denoise
GLM-04: parametric modulators only on ANTS + classifier for denies

GLM-05: parametric modulators on with durations rather than stick functions on ANTS + classifier denoise --> only liking as parametric modulator

GLM-06: parametric modulators on with durations rather than stick functions on ANTS no classifier denoise --> liking, intensity and familiarity as parametric modulators

GLM-07: parametric modulator 1; -1 for control vs reward with durations and on ANTs + classifier for denoise

GLM-08: parametric modulators with durations control vs reward with more accurate model of events of non-interest

GLM-09: parametric modulators with 2 second durations control vs reward with more accurate model of events of non-interest (to remove possible movement)

GLM-10: parametric modulators with durations control vs reward with more accurate model of events of non-interest ; we entered the estimated onset of the swall signal to remove movement

GLM-11: but on the swallowing cue; with durations (contrast taste vs tasteless --> do we get posterior insula?), control vs. reward (modeled on GLM-09) -> wrong duration and onset for swallow

GLM-12: on swallowing cue w/ stick function, control vs. reward (modeled on GLM-09)

GLM-13: on swallowing cue w/ stick function; liking, intensity and familiarity as parametric modulators (orthogonalization off)

GLM-14: on swallowing cue w/ stick function; liking, intensity and familiarity as parametric modulators (orthogonalization on)

GLM-15: on swallowing cue w/ stick function; liking as parametric modulator (orthogonalization off)

GLM-16: on swallowing cue w/ stick function; liking as parametric modulator (orthogonalization on)

GLM-17: on swallowing cue w/ stick function; intensity as parametric modulator (orthogonalization off)






TODO/TOTRY

Using GLM-09 as guide

GLM-13: add paramentric modulators (attention add "SPM.Sess(ses).U(c).orth  = 0;" (Ask david for the code to insert the modulator only if is non 0 and varies (e.g., the participant did not put all the time 50): onset liquid (moduluated by intensity,familiarity and liking)

GLM-X: on swallowing cue w/ stick function, separate onsets for control vs. reward and separate modulators

Ev se disocccupata: glm-14 CON COVARIATA SECOND LIVELLO -> chiedi a David di mostrarti quale script da REWOD


