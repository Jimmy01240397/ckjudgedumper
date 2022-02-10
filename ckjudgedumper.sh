#!/bin/bash

argnum=$#
if [ $argnum -eq 0 ]
then
    echo "usage: $0 <ckjudge cookie>"
    exit 0
fi

cookie=$1

mkdir ckjudge 2>/dev/null
cd ckjudge

cont=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems 2>/dev/null | jq -r '.problems | length')

for a in $(seq 0 1 $(($cont-1)))
do
    chapter=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems 2>/dev/null | jq -r ".problems[$a].chapter.index" | sed 's/\.//g')
    title=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems 2>/dev/null | jq -r ".problems[$a].title" | sed 's/\.//g')
    id=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems 2>/dev/null | jq -r ".problems[$a].id")
    
    echo "dumping: $chapter/$title"

    #Description
    mkdir "$chapter" 2>/dev/null
    mkdir "$chapter/$title" 2>/dev/null
    echo "<h2>$title</h2>" > "$chapter/$title/description.html"
    echo "<h3>Description</h3>" >> "$chapter/$title/description.html"
    echo "<div>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id 2>/dev/null | jq -r '.description' 2>/dev/null >> "$chapter/$title/description.html"
    echo "</div>" >> "$chapter/$title/description.html"
    echo "<p></p>" >> "$chapter/$title/description.html"
    echo "<h3>Input</h3>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id 2>/dev/null | jq -r '.inputFormat' 2>/dev/null >> "$chapter/$title/description.html"
    echo "<p></p>" >> "$chapter/$title/description.html"
    echo "<h3>Output</h3>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id 2>/dev/null | jq -r '.outputFormat' 2>/dev/null >> "$chapter/$title/description.html"
    echo "<p></p>" >> "$chapter/$title/description.html"
    echo "<h3>Loader Code</h3>" >> "$chapter/$title/description.html"
    echo "<div>" >> "$chapter/$title/description.html"
    echo '<p>Your code will be judge using this program:</p>' >> "$chapter/$title/description.html"
    echo "</div>" >> "$chapter/$title/description.html"
    echo "<pre>" >> "$chapter/$title/description.html"
    curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id 2>/dev/null | jq -r '.loaderCode' 2>/dev/null | sed 's/</<\&zwj;/g' >> "$chapter/$title/description.html"
    echo "</pre>" >> "$chapter/$title/description.html"
    
    
    #Samples
    samplecont=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id 2>/dev/null | jq -r '.samples | length' 2>/dev/null)
    for b in $(seq 0 1 $(($samplecont-1)))
    do
        echo "<div>" >> "$chapter/$title/description.html"
        echo "<h3>Sample$(($b+1))</h3>" >> "$chapter/$title/description.html"
        echo "<h4>Input</h4>" >> "$chapter/$title/description.html"
        echo "<pre>" >> "$chapter/$title/description.html"
        curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id 2>/dev/null | jq -r ".samples[$b].inputData" 2>/dev/null | sed 's/</<\&zwj;/g' >> "$chapter/$title/description.html"
        echo "</pre>" >> "$chapter/$title/description.html"
        echo "<h4>Output</h4>" >> "$chapter/$title/description.html"
        echo "<pre>" >> "$chapter/$title/description.html"
        curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/problems/$id 2>/dev/null | jq -r ".samples[$b].outputData" 2>/dev/null | sed 's/</<\&zwj;/g' >> "$chapter/$title/description.html"
        echo "</pre>" >> "$chapter/$title/description.html"
        echo "</div>" >> "$chapter/$title/description.html"
    done


    #Markdown
    pandoc --from html --to markdown "$chapter/$title/description.html" -o "$chapter/$title/Readme.md"
    
    mkdir "$chapter/$title/images" 2>/dev/null
    allbase64image=$(grep -oP '(?<=data:image/png;base64,)[A-Za-z0-9+/=]*' "$chapter/$title/Readme.md")
    for image in $allbase64image
    do
        echo $image | base64 -d > "$chapter/$title/images/$(echo $image | sha1sum | sed 's/[^a-z0-9]//g').png"
        echo "s/data:image\/png;base64,$(echo "$image" | sed 's/\//\\\//g')/\/$(echo "$chapter" | jq -sRr @uri | sed 's/%0A//g')\/$(echo "$title" | jq -sRr @uri | sed 's/%0A//g')\/images\/$(echo $image | sha1sum | sed 's/[^a-z0-9]//g')\.png/g" > /tmp/sedconf
        sed -i -f /tmp/sedconf "$chapter/$title/Readme.md"
    done

    #ans
    if [ "$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id 2>/dev/null)" = "Not signing in" ]
    then
        echo "Not signing in"
    fi

    anscont=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id 2>/dev/null | jq -r '.submissionInfo | length' 2>/dev/null)
    if [ "$anscont" != "" ]
    then
        max=$anscont
        maxscore=0
        for b in $(seq 1 1 $anscont)
        do
            if [ $max -lt $(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id 2>/dev/null | jq -r ".submissionInfo[$(($anscont-$b))].score" 2>/dev/null) ]
            then
                maxscore=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id 2>/dev/null | jq -r ".submissionInfo[$(($anscont-$b))].score" 2>/dev/null)
                max=$b
            fi
            if [ $(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id 2>/dev/null | jq -r ".submissionInfo[$(($anscont-$b))].score" 2>/dev/null) -eq 100 ]
            then
                ansid=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id 2>/dev/null | jq -r ".submissionInfo[$(($anscont-$b))].submissionId" 2>/dev/null)
                curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/code/$ansid 2>/dev/null > "$chapter/$title/ans.c"
                break
            elif [ $b -eq $anscont ]
            then
                ansid=$(curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/submission/$id 2>/dev/null | jq -r ".submissionInfo[$(($anscont-$max))].submissionId" 2>/dev/null)
                curl -H "Cookie: $1" https://ckj.csie.ncku.edu.tw/user/code/$ansid 2>/dev/null > "$chapter/$title/ans.c"
                break
            fi
        done
    fi
done



# merge and convert to markdown 
function saveUnit(){
    echo "process: ${1%/*}"
    echo "<h1>${1%/*}</h1>" > "${1%/*}/${1%/*}.html"
    for sdir in ${1%/*}/*/;
    do
        echo "    - [$(echo $sdir | sed 's/\/$//g' | sed 's/.*\///g')](/$(echo $sdir | sed 's/\/$//g' | jq -sRr @uri | sed 's/%0A//g'))" >> "Readme.md"
        cat "$sdir/description.html" >> "${1%/*}/${1%/*}.html"
    done
    cat "${1%/*}/${1%/*}.html" >> "pd1.html"
    pandoc --from html --to markdown "${1%/*}/${1%/*}.html" -o "${1%/*}/Readme.md"
}

echo "<h1>Program Design (I)</h1>" > "pd1.html"

echo "- [Program Design (I)](/pd1.md)" > "Readme.md"

for dir in L*/ 2*/; 
do
    echo "  - [$(echo $dir | sed 's/\/$//g' | sed 's/.*\///g')](/$(echo $dir | sed 's/\/$//g' | jq -sRr @uri | sed 's/%0A//g'))" >> "Readme.md"
    saveUnit $dir
done

# pd1.md 
pandoc --from html --to markdown "pd1.html" -o "pd1.md"

echo "done."
