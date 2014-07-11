DIR = "log"
SIZES = ['1000', '3000', '5000', '10000']
MODES = ['constant', 'precise']
THREADS = ['1', '2', '4', '8', '16', '24']
output_file = "total_times_noamdahl.log"

def parse_files():
    f = open(output_file, "w")
    f.write("#Non bencharked timings\n#constant first, precise last\n")
    for size in SIZES:
        temp_line = "{}\t".format(size)
        for mode in MODES:
            for thread in THREADS:
                file = open("{}/chord_{}_threads{}_{}.log".format(DIR, size, thread, mode), "r")
                line = file.read().splitlines()[-1]
                if line:
                    usrtime = float((line.split(":")[2]).split()[0])
                    systime = float((line.split(":")[3]).split()[0])
                    tottime = usrtime + systime
                # tuples containing (sequential,parallel) time
                    temp_line += "{}\t".format(tottime)
                else:
                    temp_line += "?\t?\t"
        f.write(temp_line + "\n")
    f.close()
if __name__ == "__main__":
    parse_files()
    exit(0)
