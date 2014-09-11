DIR = "./logs"                     # The dir where to gather the logs
MODES = ['constant', 'precise']    # The modes you want to analyse
OUTPUT_FILE = "./total_times.csv"  # Modify this name to one of your preference

SIZES = ['1000', '3000', '10000', '25000', '30000', '50000', '75000', '100000']
THREADS = ['2', '4', '8', '16', '24']

# If you make several test of the same experiment, you can name the log files
# with a prefix ('1_chord..., 2_chord...') and then put the prefixes
# you used in input_seq. The script will average the corresponding values
# for you.
input_seq = ['']


def parse_elapsed_real(line):
    return float((line.split()[0]).split(':')[1])


def parse_user_kernel(line):
    usrtime = float((line.split(":")[2]).split()[0])
    systime = float((line.split(":")[3]).split()[0])
    sumtime = usrtime + systime
    return sumtime


def parse_files(elapsed=True):
    f = open(OUTPUT_FILE, "w")
    # f.write("#Non bencharked timings\n#constant first, precise last\n")
    for size in SIZES:
        temp_line = "{}".format(size)
        for mode in MODES:
            for thread in THREADS:
                sum_l = 0.
                leng = len(input_seq)
                for seq in input_seq:
                    file = open("{}/chord{}_{}_threads{}_{}.log".format(DIR,
                                seq, size, thread, mode), "r")
                    line = file.read().splitlines()[-1]
                    if line:
                        if elapsed:
                            sum_l += parse_elapsed_real(line)
                        else:
                            sum_l += parse_user_kernel(line)
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

    options, args = parser.parse_args()
    if options.elapsed:
        parse_files()
    elif options.userkernel:
        parse_files(elapsed=False)

    exit(0)
