# This script is used by testall_sr.sh to filter the output data of
# SimGrid when TIME_BENCH_PER_SR is enabled.
# Observation: due to the giant amount of logs that XBT_VERB generates, I
# recommend to change the printing statements related to TIME_BENCH_PER_SR to
# 'CRITICAL' and set the threshold of logs to 'critical' (this threshold is
# already setted in testall*.sh, so you want to check there to know how to
# do it by yourself). That workaround gives less logs to analyze and
# accelerates the simulation.

import sys


def parse_critical_output(filename, output):
    file = open(filename, "r")
    lines = file.read().splitlines()
    lines = [line for line in lines if "Total time SR" in line]
    lines = [line.split("]")[-1] for line in lines]
    lines = [(int(line.split()[3]),float((line.split()[5])[:-1]),int(line.split()[6])) for line in lines]
    with open(output, "w") as f:
        f.write("#id_sr\ttime_taken\tnum_proccess\n")
        for line in lines:
            f.write("{}\t{}\t{}\n".format(str(line[0]), str(line[1]), str(line[2])))

if __name__ == "__main__":
    if len(sys.argv)<3:
        print("You need to provide input & output files!")
        exit("No filenames provided.")
    filename = sys.argv[1]
    output = sys.argv[2]
    parse_critical_output(filename, output)
    exit(0)
