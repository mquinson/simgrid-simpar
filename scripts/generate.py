#!/usr/bin/python

# This script generates a specific deployment file for the Chord example.
# It assumes that the platform will be a cluster.
# Usage: python generate.py nb_nodes nb_bits end_date
# Example: python generate.py 100000 32 1000

import random


def platform(nb_nodes, nb_bits, end_date):
  max_id = 2 ** nb_bits - 1
  all_ids = [42]
  res = ["<?xml version='1.0'?>\n"
  "<!DOCTYPE platform SYSTEM \"http://simgrid.gforge.inria.fr/simgrid.dtd\">\n"]
  res.append("<!-- nodes: %d, bits: %d, date: %d -->\n"%(nb_nodes, nb_bits, end_date))
  res.append("<platform version=\"3\">\n"
  "  <process host=\"c-0.me\" function=\"node\"><argument value=\"42\"/><argument value=\"%d\"/></process>\n" % end_date)

  for i in range(1, nb_nodes):
    ok = False
    while not ok:
      my_id = random.randint(0, max_id)
      ok = not my_id in all_ids

    known_id = all_ids[random.randint(0, len(all_ids) - 1)]
    start_date = i * 10
    res.append("  <process host=\"c-%d.me\" function=\"node\"><argument value=\"%d\" /><argument value=\"%d\" /><argument value=\"%d\" /><argument value=\"%d\" /></process>\n" % (i, my_id, known_id, start_date, end_date))
    all_ids.append(my_id)

  res.append("</platform>")
  return "".join(res)

def deploy(nb_nodes):
  return """<?xml version='1.0'?>
<!DOCTYPE platform SYSTEM "http://simgrid.gforge.inria.fr/simgrid.dtd">

<!--              _________
				|	       |
				|  router  |
				|__________|
					/ | \
				   /  |  \
			   l0 / l1|   \l2
				 /    |    \
				/	  |     \
			host0   host1   host2
-->

<platform version="3">
<AS  id="AS0"  routing="Full">
  <cluster id="my_cluster_1" prefix="c-" suffix=".me"
  		radical="0-%d"	power="1000000000"    bw="125000000"     lat="5E-5"/>
</AS>
</platform>"""%(nb_nodes-1)

if __name__=="__main__":
  import sys
  from optparse import OptionParser
  parser = OptionParser()
  parser.add_option("-p", "--platform", action="store_true",
                    default=False, dest="platform",
                    help="generate platform file")
  parser.add_option("-d", "--deploy", action="store_true",
                    default=False, dest="deploy",
                    help="generate deploy file")
  parser.add_option("-n", "--nodes", action="store",
                    type="int", dest="nodes", default=None,
                    help="Number of nodes")
  parser.add_option("-b", "--bits", action="store",
                    type="int", dest="bits", default=None,
                    help="Number of bits")
  parser.add_option("-e", "--end_date", action="store",
                    type="int", dest="end_date", default=None,
                    help="End date")
  parser.set_usage("%prog [options]")
  options, args = parser.parse_args()

  if options.platform:
    if (options.nodes is None): print "Option -n must be declared with -p";sys.exit(1)
    if (options.bits is None): print "Option -b must be declared with -p";sys.exit(1)
    if (options.end_date is None): print "Option -e must be declared with -p";sys.exit(1)
    f = open("chord%d.xml"%options.nodes, "w")
    f.write(platform(options.nodes, options.bits, options.end_date))
    f.close()

  if options.deploy:
    if (options.nodes is None): print "Option -n must be declared with -d";sys.exit(1)
    f = open("One_cluster_nobb_%d_hosts.xml"%options.nodes, "w")
    f.write(deploy(options.nodes))
    f.close()




