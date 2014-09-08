DIR = "log"  # The dir where to gather the logs
MODES = ['constant', 'precise']  # The modes you want to analyse
SIZES = ['1000', '3000', '10000', '30000', '100000']  #, '100000'] #, '300000']
THREADS = ['2', '4', '8', '16', '24']
output_file = "total_times.csv"  # Modify this name to a proper one.

input_seq = ['']  # If you make several test of the same experiment, you can
                  # name the log files with a
                  # prefix ('1_chord..., 2_chord...') and then put the prefixes
                  # you used here. The script will average the corresponding
                  # values for you.


def parse_files():
    f = open(output_file, "w")
    # f.write("#Non bencharked timings\n#constant first, precise last\n")
    for size in SIZES:
        temp_line = "{}".format(size)
        for mode in MODES:
            for thread in THREADS:
                sum_l = 0.
                leng = len(input_seq)
                for seq in input_seq:
                    file = open("{}/chord{}_{}_threads{}_{}.log".format(DIR, seq, size, thread, mode), "r")
                    line = file.read().splitlines()[-1]
                    if line:
                        usrtime = float((line.split(":")[2]).split()[0])
                        systime = float((line.split(":")[3]).split()[0])
                        sum_l = usrtime + systime
                    # tuples containing (sequential,parallel) time
                    else:
                        leng -= 1
                if leng != 0:
                    temp_line += ",{}".format(sum_l / float(leng))
                else:
                    temp_line += ",?"
        f.write(temp_line + "\n")
    f.close()
if __name__ == "__main__":
    parse_files()
    exit(0)
