DIR = "logs"
MODES = ['constant', 'precise']
SIZES = ['1000', '3000', '10000', '25000', '50000', '75000'] #, '100000'] #, '300000']
THREADS = ['2', '4', '8', '16', '24']
output_file = "total_times_adaptive.log"
input_seq = ['']


def parse_files():
    f = open(output_file, "w")
    f.write("##constant first, precise last\n")
    for size in SIZES:
        temp_line = "{}\t".format(size)
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
                    temp_line += "{}\t".format(sum_l / float(leng))
                else:
                    temp_line += "?\t?\t"
        f.write(temp_line + "\n")
    f.close()
if __name__ == "__main__":
    parse_files()
    exit(0)
