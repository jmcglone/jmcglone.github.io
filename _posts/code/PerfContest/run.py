import sys
import subprocess
import os

refOutput = "Count: 1028"
appName = "sieve"
verbose = False
for arg in sys.argv:   
  if arg == "-v":
    verbose = True

saveCwd = os.getcwd()

if verbose:
  print ("Building ...")

for root, dirs, files in os.walk(os.getcwd()):
  for submission in dirs:
    os.chdir(os.path.join(os.path.join(root, submission)))
    try:
      buildCmd = os.path.join(os.path.join(root, submission), "build.sh") + " &> /dev/null"
      if verbose:
        print(buildCmd)
      output = subprocess.check_output(buildCmd, shell=True)
      if not output:
        print(submission + " - build - OK")
      else:
        print(submission + " - build - Failed")
    except:
      print(submission + " - build - Failed")

os.chdir(saveCwd)

if verbose:
  print ("Running ...")

scoretable = []

baseline = float(0)

for root, dirs, files in os.walk(os.getcwd()):
  for submission in dirs:
    os.chdir(os.path.join(os.path.join(root, submission)))
    scores = []
    runCmd = "time -p " + os.path.join(os.path.join(root, submission), appName) + " 2>&1"
    if verbose:
      print runCmd
    for x in range(0, 10):
      output = subprocess.check_output(runCmd, shell=True) 
      appOutput = ""
      collectAppOutput = True
      for row in output.split('\n'):
        if 'real' in row:
          collectAppOutput = False
          if not refOutput == appOutput:
            print(submission + " - Validation failed!")
            print("Reference output: " + refOutput)
            print("App output      : " + appOutput)
          real, time = row.split(' ')
          scores.append(float(time))
        elif collectAppOutput:
          appOutput += row
    copyScores = scores    
    copyScores.sort()
    minScore = copyScores[0]
    scoretable.append([minScore, submission, scores])
    if (submission == "baseline"):
      baseline = minScore

scoretable.sort()
for score in scoretable:
    if (score[0] > 0):
      print(score, " + " + str(round(baseline / score[0], 2)) + "x")
    else:
      print(score, " + inf")
