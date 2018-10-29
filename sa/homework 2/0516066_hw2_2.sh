#!/bin/sh
Show_Classroom="FALSE"
Extra_Column="TRUE"
INPUT=tmp.input
maxline=0
column="A B C D E F G H I J K L"
extra="M N X Y"

download(){
    [ -f timetable.JSON ] || curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > timetable.JSON
    init
}

init(){
    
    awk 'BEGIN{FS="\","} {for (i=1; i <= NF; i++) print $i}' timetable.JSON | grep "cos_ename" | sed 's/"cos_ename":"//g' > tmp.COS_ENAME
    awk 'BEGIN{FS="\","} {for (i=1; i <= NF; i++) print $i}' timetable.JSON | grep "cos_time" | sed 's/"cos_time":"//g' | sed 's/[1-7][A-Z]*/&,/g' | awk 'BEGIN{FS=","}{for(i=1;i <= NF;i++)if($i~/[1-7][A-Z]+/) printf("%s ", $i)}{printf("\n")}' | sed 's/ /,/g' | sed 's/,$//g' > tmp.COS_TIME
    awk 'BEGIN{FS="\","} {for (i=1; i <= NF; i++) print $i}' timetable.JSON | grep "cos_time" | sed 's/"cos_time":"//g' | awk 'BEGIN{FS="-|,"; OFS=","}{print $2,$4}' | sed 's/,$//g' > tmp.COS_PLACE
    
    i=1
    maxline=$(wc -l tmp.COS_ENAME | awk '{print $1}')
    printf "" > tmp.class
    while [ $i -le $maxline ];do
    
        awk -v i=$i 'NR == i' tmp.COS_TIME | tr -d '\n' >> tmp.class
        printf " " >> tmp.class
        awk -v i=$i 'NR == i' tmp.COS_PLACE | tr -d '\n' >> tmp.class
        printf " - " >> tmp.class
        awk -v i=$i 'NR == i' tmp.COS_ENAME >> tmp.class
        
        i=$(($i+1))        

    done

}

timetable(){
    
    if [ ! -f tmp.curriculum ];then
        
        printf "|== |============ |============ |============ |============ |============ |============ |============ |\n" > tmp.curriculum
        printf "|   |Mon          |Tue          |Wed          |The          |Fri          |Sat          |Sun          |\n" >> tmp.curriculum
        printf "|== |============ |============ |============ |============ |============ |============ |============ |\n" >> tmp.curriculum 
           
        i=1
        j=0
        while [ $i -le 16 ]; do
            
            case $i in
            1)
                j=$(($j+1))
                ch=$(echo $extra | awk -v j="$j" '{print $j}')
            ;;
            2)
                j=$(($j+1))
                ch=$(echo $extra | awk -v j="$j" '{print $j}')
            ;;
            7)
                j=$(($j+1))
                ch=$(echo $extra | awk -v j="$j" '{print $j}')
            ;;
            12)
                j=$(($j+1))
                ch=$(echo $extra | awk -v j="$j" '{print $j}')
            ;;
            *)
                ch=$(echo $column | awk -v i="$i" -v j="$j" '{print $(i-j)}')
            ;;
            esac
            
            
            printf "|%c  |x.           |x.           |x.           |x.           |x.           |x.           |x.           |\n" $ch >> tmp.curriculum
            printf "|.  |.            |.            |.            |.            |.            |.            |.            |\n" >> tmp.curriculum
            printf "|.  |.            |.            |.            |.            |.            |.            |.            |\n" >> tmp.curriculum
            printf "|.  |.            |.            |.            |.            |.            |.            |.            |\n" >> tmp.curriculum
            printf "|== |============ |============ |============ |============ |============ |============ |============ |\n" >> tmp.curriculum
            
            i=$(($i+1))
              
        done
        
        cat tmp.curriculum > tmp.classroom
        
        dialog --title "TimeTable" \
        --ok-label "Add Class" \
        --extra-button \
        --extra-label "Option" \
        --textbox tmp.curriculum 50 120
        
        response=$?
        case $response in
            0) 
                pickclass
            ;;
            3) 
                option
            ;;
        esac
            
    elif [ -f tmp.curriculum ];then    
      
        if [ ${Extra_Column} ==  "TRUE" ];then
            
            if [ ${Show_Classroom} ==  "FALSE" ];then
            
                dialog --title "TimeTable" \
                --ok-label "Add Class" \
                --extra-button \
                --extra-label "Option" \
                --textbox tmp.curriculum 50 120
                
                response=$?
                case $response in
                    0) 
                        pickclass
                    ;;
                    3) 
                        option
                    ;;
                esac
            else
            
                dialog --title "TimeTable" \
                --ok-label "Add Class" \
                --extra-button \
                --extra-label "Option" \
                --textbox tmp.classroom 50 120
                
                response=$?
                case $response in
                    0) 
                        pickclass
                    ;;
                    3) 
                        option
                    ;;
                esac
            fi
        
        elif [ ${Extra_Column} == "FALSE" ];then  
            
            if [ ${Show_Classroom} ==  "FALSE" ];then
                
                cat tmp.curriculum | awk 'BEGIN{FS="|";OFS="|"}{print $1,$2,$3,$4,$5,$6,$7,$1}' | awk 'BEGIN{FS="|";OFS="|"}{if(NR != 4 && NR != 5 && NR != 6 && NR != 7 && NR != 8 && NR != 9 && NR != 10 && NR != 11 && NR != 12 && NR != 13 && NR != 34 && NR != 35 && NR != 36 && NR != 37 && NR != 38 && NR != 59 && NR != 60 && NR != 61 && NR != 62 && NR != 63) print $0}'> tmp.false_curriculum
                
                dialog --title "TimeTable" \
                --ok-label "Add Class" \
                --extra-button \
                --extra-label "Option" \
                --textbox tmp.false_curriculum 50 120
                
                response=$?
                case $response in
                    0) 
                        pickclass
                    ;;
                    3) 
                        option
                    ;;
                esac
                
            else
                
                cat tmp.classroom | awk 'BEGIN{FS="|";OFS="|"}{print $1,$2,$3,$4,$5,$6,$7,$1}' | awk 'BEGIN{FS="|";OFS="|"}{if(NR != 4 && NR != 5 && NR != 6 && NR != 7 && NR != 8 && NR != 9 && NR != 10 && NR != 11 && NR != 12 && NR != 13 && NR != 34 && NR != 35 && NR != 36 && NR != 37 && NR != 38 && NR != 59 && NR != 60 && NR != 61 && NR != 62 && NR != 63) print $0}'> tmp.false_classroom
                
                dialog --title "TimeTable" \
                --ok-label "Add Class" \
                --extra-button \
                --extra-label "Option" \
                --textbox tmp.false_classroom 50 120
                
                response=$?
                case $response in
                    0) 
                        pickclass
                    ;;
                    3) 
                        option
                    ;;
                esac
            fi
        fi  
    fi
    
   	
}

pickclass(){
    
    IFS=$'\n'
    lines=$(cat tmp.class)
    dialog --noitem --menu "Add Class" 80 80 ${maxline} ${lines} \
    2> tmp.input
    addclass
}

addclass(){
    
    
    
    class=$(echo $(cat tmp.input))
    time=$(awk '{print $1}' tmp.input)
    place=$(awk '{print $2}' tmp.input)
    if [ $place == "-" ];then 
        name=$(awk '{print substr($0, index($0,$3)) }' tmp.input)
    else
        name=$(awk '{print substr($0, index($0,$4)) }' tmp.input)
    fi
    
    table=$(cat tmp.curriculum)
    IFS=","
    conflict="FALSE"
    for line in $time
    do
        num=$(echo $line | cut -c1-1)
        str=$( echo $line | cut -c2- )                                                                                                                                
        while [ $str ];do
            letter=$(echo $str | cut -c1-1)
            row=$(echo $table | awk -v letter=$letter '{for(i=1;i<=NR;i++) if($1~letter)print i}' | awk 'END{print}')
            data=$(echo $table | awk -v row=$row -v num=$num 'BEGIN{FS="|";OFS="|"}NR==row{print $(num+2)}')
            
            if ! echo $data | grep -q '^x'
            then
                conflict="TRUE"
                echo $num$letter >> tmp.conflict
            else
                echo $num$letter $time $place>> tmp.possible_class  
            fi
            str=$( echo $str | cut -c2- )    
        done
         
    done
    
    
    if [ $conflict == "FALSE" ];then
        add=$(cat tmp.possible_class)
        rm tmp.possible_class
        c_time=$( echo $add | awk '{print $1}' )
        IFS=$'\n'
        for t in $c_time
        do
            
            IFS=""
            week=$( echo $t | cut -c1-1 )
            session=$( echo $t | cut -c2- )
            week_to_c=$(($week+2))
            session_to_r=$(echo $table | awk -v session=$session '{for(i=1;i<=NR;i++) if($1~session)print i}' | awk 'END{print}')
            len=${#name}
            
            len_p=${#place}
            table_p=$(cat tmp.classroom)
            k_p=$((13-$len_p))
            line_p=$(printf $place%${k_p}s)
            echo $table_p | awk -v row=$session_to_r -v col=$week_to_c -v line_p=$line_p 'BEGIN{FS="|";OFS="|"}NR==row{$col=line_p}{print}' > tmp.classroom
            
            echo $t $place $name >> tmp.current_class
              
            if [ $len -lt 13 ];then
                table=$(cat tmp.curriculum)
                k=$((13-$len))
                line=$(printf $name%${k}s)
                echo $table | awk -v row=$session_to_r -v col=$week_to_c -v line=$line 'BEGIN{FS="|";OFS="|"}NR==row{$col=line}{print}' > tmp.curriculum
            elif [ $len -gt 13 ];then
                i=0
                while [ $len -gt 13 ];do
                    table=$(cat tmp.curriculum)
                    st=$(($i*13+1))
                    ed=$(($st+12))
                    len=$(($len-13))                                                                                                                                          
                    line=$(echo $name | cut -c${st}-${ed})   
                    echo $table | awk -v row=$session_to_r -v col=$week_to_c -v line=$line 'BEGIN{FS="|";OFS="|"}NR==row{$col=line}{print}' > tmp.curriculum
                    i=$(($i+1))
                    session_to_r=$(($session_to_r+1))
                done
                table=$(cat tmp.curriculum)
                st=$(($i*13+1))
                ed=$(($st+$len))
                k=$((13-$len))
                line=$(echo $name | cut -c${st}-${ed})
                line=$(printf $line%${k}s)
                echo $table | awk -v row=$session_to_r -v col=$week_to_c -v line=$line 'BEGIN{FS="|";OFS="|"}NR==row{$col=line}{print}' > tmp.curriculum
            else    
            fi
        
        done
        timetable
    else
        if [ -f tmp.possible_class ];then
            rm tmp.possible_class
        fi
        
        cft=$(cat tmp.conflict)
        IFS=$'\n'
        for cft_time in $cft
        do
            echo Collision:  $cft_time >> tmp.err
            cat tmp.current_class | awk -v t=$cft_time '{if($1~t)print substr($0, index($0,$3))}' >> tmp.err
        done
        dialog --title 'Collision' --exit-label "OK" --textbox tmp.err 20 50
        rm tmp.err
        rm tmp.conflict
        pickclass  
    fi
    

}

option(){
    
    if [ $Extra_Column == "FALSE" ];then
    
        if [ $Show_Classroom == "FALSE" ];then
            dialog --title "Option" --menu "CRS Options Menu" 12 35 2 \
            "Op1" "Show Classroom" \
            "Op2" "Show Extra Column" \
            2> "${INPUT}"
            result=$?
            
          	if [ ! ${result} -eq 0 ]; then
          		timetable
          	fi
            menuitem=`cat $INPUT`
            
            case $menuitem in 
                Op1)
                    Show_Classroom="TRUE"
                    timetable
                ;;
                Op2)
                    Extra_Column="TRUE"
                    timetable
                ;;
                
            esac
            
        elif [ $Show_Classroom == "TRUE" ];then
            dialog --title "Option" --menu "CRS Options Menu" 12 35 2 \
            "Op1" "Hind Classroom" \
            "Op2" "Show Extra Column" \
            2> "${INPUT}"
            result=$?
          	if [ ! ${result} -eq 0 ]; then
          		timetable
          	fi
            menuitem=`cat $INPUT`
            
            case $menuitem in 
                Op1)
                    Show_Classroom="FALSE"
                    timetable
                ;;
                Op2)
                    Extra_Column="TRUE"
                    timetable
                ;;
            esac
        fi
        
    elif [ $Extra_Column == "TRUE" ];then
    
        if [ $Show_Classroom == "FALSE" ];then
            dialog --title "Option" --menu "CRS Options Menu" 12 35 2 \
            "Op1" "Show Classroom" \
            "Op2" "Hind Extra Column" \
            2> "${INPUT}"
            result=$?
          	if [ ! ${result} -eq 0 ]; then
          		timetable
          	fi
            menuitem=`cat $INPUT`
            
            case $menuitem in 
                Op1)
                    Show_Classroom="TRUE"
                    timetable
                ;;
                Op2)
                    Extra_Column="FALSE"
                    timetable
                ;;
            esac
            
        elif [ $Show_Classroom == "TRUE" ];then
            dialog --title "Option" --menu "CRS Options Menu" 12 35 2 \
            "Op1" "Hind Classroom" \
            "Op2" "Hind Extra Column" \
            2> "${INPUT}"
            result=$?
          	if [ ! ${result} -eq 0 ]; then
          		timetable
          	fi
            menuitem=`cat $INPUT`
            
            case $menuitem in 
                Op1)
                    Show_Classroom="FALSE"
                    timetable
                ;;
                Op2)
                    Extra_Column="FALSE"
                    timetable
                ;;
            esac
        fi
    fi
        
        
}

download
timetable