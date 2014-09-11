DIR = "./logs"                     # The dir where to gather the logs
MODES = ['constant', 'precise']    # The modes to analyse
OUTPUT_FILE = "./total_times.csv"  # Put proper name here

SIZES = ['1000', '3000', '10000', '25000', '50000', '75000', '100000']
THREADS = ['2', '4', '8', '16', '24']

# If you make several test of the same experiment, you can name the log files
# with a prefix ('1_chord..., 2_chord...') and then put the prefixes
# you used in input_seq. The script will average the corresponding values
# for you.
input_seq = ['']


def parse_elapsed_real(file):
    line = file.read().splitlines()[-1]
    if line:
        return float((line.split()[0]).split(':')[1])
    else:
        return 0


def parse_user_kernel(file):
    line = file.read().splitlines()[-1]
    if line:
        usrtime = float((line.split(":")[2]).split()[0])
        systime = float((line.split(":")[3]).split()[0])
        return usrtime + systime


def parse_amdahl_times(file):
    line = [line for line in file.read().splitlines() if "Amdahl" in line]
    line = [(((l.split(";")[0]).split(":")[-1]).strip(),
            ((l.split(";")[1]).split(":")[1]).strip())
            for l in line][0]
    return float(line[0]) + float(line[1])


def print_header(file):
    file.write('"nodes"')
    for mode in MODES:
        for thread in THREADS:
            file.write(',"'+mode[0]+thread+'"')
    file.write('\n')


def parse_files(elapsed=False, amdahl=False):
    f = open(OUTPUT_FILE, "w")
    print_header(f)
    for size in SIZES:
        temp_line = "{}".format(size)
        for mode in MODES:
            for thread in THREADS:
                sum_l = 0.
                leng = len(input_seq)
                for seq in input_seq:
                    file = open("{}/chord{}_{}_threads{}_{}.log".format(DIR,
                                seq, size, thread, mode), "r")
                    if elapsed:
                        sum_l += parse_elapsed_real(file)
                    elif amdahl:
                        sum_l += parse_amdahl_times(file)
                    else:
                        sum_l += parse_user_kernel(file)
                if leng != 0:
                    temp_line += ",{}".format(sum_l / float(leng))
                else:
                    temp_line += ",?"
        f.write(temp_line + "\n")
    f.close()


if __name__ == "__main__":
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-e", action="store_true",
                      dest="elapsed",
                      help="Generate table using real elapsed time from logs")
    parser.add_option("-u", action="store_true",
                      dest="userkernel",
                      help="Generate table using user+kernel time from logs")
    parser.add_option("-a", action="store_true",
                      dest="amdahl",
                      help="Generate table using amdahl times from logs")

    options, args = parser.parse_args()
    if options.elapsed:
        parse_files(elapsed=True)
    elif options.userkernel:
        parse_files(elapsed=False)
    elif options.amdahl:
        parse_files(amdahl=True)

    exit(0)
