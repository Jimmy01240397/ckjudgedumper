#!/bin/bash

argnum=$#
if [ $argnum -eq 0 ]
then
    echo "usage: $0 <ckjudge cookie>"
    exit 0
fi

cookie=$1

mkdir ckjudge
cd ckjudge

cont=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems | jq -r '.problems | length')

for a in $(seq 0 1 $(($cont-1)))
do
    chapter=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems | jq -r ".problems[$a].chapter.index")
    title=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems | jq -r ".problems[$a].title")
    id=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems | jq -r ".problems[$a].id")
    
    #Description
    mkdir "$chapter"
    mkdir "$chapter/$title"
    echo "<h3>Description</h3>" > "$chapter/$title/description.html"
    echo "<div>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id | jq -r '.description' 2>/dev/null >> "$chapter/$title/description.html"
    echo "</div>" >> "$chapter/$title/description.html"
    echo "<p></p>" >> "$chapter/$title/description.html"
    echo "<h3>Input</h3>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id | jq -r '.inputFormat' 2>/dev/null >> "$chapter/$title/description.html"
    echo "<p></p>" >> "$chapter/$title/description.html"
    echo "<h3>Output</h3>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id | jq -r '.outputFormat' 2>/dev/null >> "$chapter/$title/description.html"
    echo "<p></p>" >> "$chapter/$title/description.html"
    echo "<h3>Loader Code</h3>" >> "$chapter/$title/description.html"
    echo "<div>" >> "$chapter/$title/description.html"
    echo '<p>Your code will be judge using this program:</p>' >> "$chapter/$title/description.html"
    echo "</div>" >> "$chapter/$title/description.html"
    echo "<pre>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id | jq -r '.loaderCode' 2>/dev/null >> "$chapter/$title/description.html"
    echo "</pre>" >> "$chapter/$title/description.html"
    
    
    #Samples
    samplecont=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id | jq -r '.samples | length' 2>/dev/null)
    > "$chapter/$title/samples.html"
    for b in $(seq 0 1 $(($samplecont-1)))
    do
        echo "<div>" >> "$chapter/$title/samples.html"
        echo "<h3>Sample$(($b+1))</h3>" >> "$chapter/$title/samples.html"
        echo "<h4>Input</h4>" >> "$chapter/$title/samples.html"
        echo "<pre>" >> "$chapter/$title/samples.html"
        curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id | jq -r ".samples[$b].inputData" 2>/dev/null >> "$chapter/$title/samples.html"
        echo "</pre>" >> "$chapter/$title/samples.html"
        echo "<h4>Output</h4>" >> "$chapter/$title/samples.html"
        echo "<pre>" >> "$chapter/$title/samples.html"
        curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id | jq -r ".samples[$b].outputData" 2>/dev/null >> "$chapter/$title/samples.html"
        echo "</pre>" >> "$chapter/$title/samples.html"
        echo "</div>" >> "$chapter/$title/samples.html"
    done

    #ans
    anscont=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id | jq -r '.submissionInfo | length' 2>/dev/null)
    if [ "$anscont" != "" ]
    then
        for b in $(seq 1 1 $anscont)
        do
            if [ $(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id | jq -r ".submissionInfo[$(($anscont-$b))].score" 2>/dev/null) -eq 100 ] || [ $b -eq $anscont ]
            then
                ansid=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id | jq -r ".submissionInfo[$(($anscont-$b))].submissionId" 2>/dev/null)
                curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/code/$ansid > "$chapter/$title/ans.c"
                break
            fi
        done
    fi
done
