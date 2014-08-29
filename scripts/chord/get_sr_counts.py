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
