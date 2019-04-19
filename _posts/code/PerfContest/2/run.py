import sys
import subprocess
import os
import shutil
import argparse

# python run.py -v [-build] [-run] [-submission=<folder>]
# Instructions:
# Script runs through all the folders in current dir and tries 
# to build and run each submission.
#
# Run "git clone https://github.com/llvm-mirror/test-suite" 
# in current dir or copy clean sources in ./test-suite
#
# In each submission folder there should be a patch file
# named "src.patch". Baseline folder is allowed to have
# no modifications, i.e. no patch.
#
# Typical workflow: once you modified baseline, create a patch 
# out of your modifications, name it "src.patch" and put it 
# in new folder. This will be you new attempt to optimize 
# the benchmark.

parser = argparse.ArgumentParser(description='test submissions')
parser.add_argument("-v", help="verbose", action="store_true", default=False)
parser.add_argument("-build", help="only build", action="store_true", default=False)
parser.add_argument("-run", help="only run", action="store_true", default=False)
parser.add_argument("-submission", type=str, help="do single submission", default="")
args = parser.parse_args()

verbose = args.v
buildOnly = args.build
runOnly = args.run
buildAndRun = not runOnly and not buildOnly
doSubmission = args.submission

saveCwd = os.getcwd()

testSuiteDir = os.path.join(os.getcwd(),"test-suite")

submissions = list(tuple())

if verbose:
  print ("Submissions:")

for submission in os.listdir(os.getcwd()):
  if not submission == "test-suite":
    if not os.path.isfile(os.path.join(os.getcwd(), submission)):
      submissions.append((submission, os.path.join(os.getcwd(), submission)))
      if verbose:
        print ("  " + submission)

if buildOnly or buildAndRun:
  if verbose:
    print ("Building ...")

  for submissionName, submissionDir in submissions:
    if not doSubmission or (doSubmission and doSubmission == submissionName):

      if verbose:
        print ("Building " + submissionName + " ...")

      submissionBuildDir = os.path.join(submissionDir, "build")
      if os.path.exists(submissionBuildDir):
        shutil.rmtree(submissionBuildDir)
 
      submissionSrcDir = os.path.join(submissionDir,"test-suite")
      if os.path.exists(submissionSrcDir):
        shutil.rmtree(submissionSrcDir)
    
      shutil.copytree(testSuiteDir, submissionSrcDir)
      print("  copying sources - OK")

      if not submissionName == "baseline":
        os.chdir(submissionSrcDir)    
        try:
          subprocess.check_call("git apply ../src.patch", shell=True)
          print("  applying patch - OK")
        except:
          print("  applying patch - Failed")

      os.mkdir(submissionBuildDir)
      os.chdir(submissionBuildDir)    

      try:
        subprocess.check_call("cmake -DTEST_SUITE_COLLECT_CODE_SIZE=OFF -DTEST_SUITE_BENCHMARKING_ONLY=ON -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_C_FLAGS=\"-O3 -march=core-avx2\" -DCMAKE_CXX_FLAGS=\"-O3 -march=core-avx2\" ../test-suite/ &> /dev/null", shell=True)
        print("  cmake - OK")
      except:
        print("  cmake - Failed")

      try:
        subprocess.check_call("make 7zip-benchmark -j6 &> /dev/null", shell=True)
        print("  make - OK")
      except:
        print("  make - Failed")

os.chdir(saveCwd)

if runOnly or buildAndRun:
  if verbose:
    print ("Running ...")

  scoretable = []

  baseline = float(0)

  for submissionName, submissionDir in submissions:
    if not doSubmission or (doSubmission and doSubmission == submissionName):

      if verbose:
        print ("Running " + submissionName + " ...")

      submissionBuildDir = os.path.join(submissionDir, "build")
      os.chdir(submissionBuildDir)
      scores = []
      runCmd = "time -p ./MultiSource/Benchmarks/7zip/7zip-benchmark b 2>&1"
      output = subprocess.check_output(runCmd, shell=True)
      valid = True
      for row in output.split('\n'):
        if 'Decoding Error' in row:
          print("  validation - Failed!")
          valid = False
     
      if valid:
        print("  validation - OK")

      for x in range(0, 10):
        output = subprocess.check_output(runCmd, shell=True) 
        for row in output.split('\n'):
          if 'real' in row:
            real, time = row.split(' ')
            scores.append(float(time))

      copyScores = scores    
      copyScores.sort()
      minScore = copyScores[0]
      scoretable.append([minScore, submissionName, scores])
      if (submissionName == "baseline"):
        baseline = minScore

  scoretable.sort()
  for score in scoretable:
      if (score[0] > 0):
        print(score, " + " + str(round(baseline / score[0], 2)) + "x")
      else:
        print(score, " + inf")
