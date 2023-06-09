CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone $1 student-submission 2> /dev/null
echo 'Submission Cloned'

# check submission for correct file

student_file=`find student-submission -name ListExamples.java`
if ! [[ -f $student_file ]]
then 
    echo "Student submission not found"
    exit
else 
    echo "Student submission found. Path: $student_file"
fi

# copy all relevant files to grading-area
cp $student_file TestListExamples.java grading-area/

# compile Java files
cd grading-area
javac -cp ".;../lib/hamcrest-core-1.3.jar;../lib/junit-4.13.2.jar" *.java
if [[ $? -eq 1 ]]
then 
    echo "ERROR: Java file cannot be compiled. Exit code 1"
    exit
fi

# run JUnit tests
echo "Running JUnit tests..."
java -cp ".;../lib/junit-4.13.2.jar;../lib/hamcrest-core-1.3.jar" org.junit.runner.JUnitCore TestListExamples > grade-results.txt
grep "Tests run" grade-results.txt > fail-results.txt
grep "OK" grade-results.txt > succ-results.txt

failcheck=`wc fail-results.txt`

echo "Tests completed. Results shown below:"
if [[ $failcheck == "0 0 0 fail-results.txt" ]]
then 
    echo "All tests passed!"
else 
    failmsg=$(head -n 1 fail-results.txt)
    testcnt=${failmsg:11:1}
    failcnt=${failmsg:25:2}
    succcnt=$(($testcnt - $failcnt))
    echo "Score: $succcnt / $testcnt"
fi