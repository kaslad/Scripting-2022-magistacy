#!/bin/bash

paint(){
    clear
    echo "Ход: $STEP"
    D="-----------------"
    S="%s\n|%3s|%3s|%3s|%3s|\n"
    printf $S $D ${M[0]:-"."} ${M[1]:-"."} ${M[2]:-"."} ${M[3]:-"."}
    printf $S $D ${M[4]:-"."} ${M[5]:-"."} ${M[6]:-"."} ${M[7]:-"."}
    printf $S $D ${M[8]:-"."} ${M[9]:-"."} ${M[10]:-"."} ${M[11]:-"."}
    printf $S $D ${M[12]:-"."} ${M[13]:-"."} ${M[14]:-"."} ${M[15]:-"."}
    echo $D
    if (( ${#AVAILABLE_MOVS[@]} != 0 )); then
        echo "Неверный ход! Невозможно костяшку $INPUT_STRING передвинуть на пустую ячейку"
        echo "Можно выбрать: "
        for iter in "${AVAILABLE_MOVS[@]}"
        do
          echo -n "$iter "
        done
        echo ""
    fi
    AVAILABLE_MOVS=()
}

swap(){
    M[$EMPTY]=${M[$1]}
    M[$1]=""
    EMPTY=$1
}

quit_play(){
    while :
    do
        read -n 1 -s -p "Вы действительно хотите выйти [y/n]?"
        case $REPLY in
            y|Y) exit
            ;;
            n|N) return
            ;;
        esac
    done

}

validate_win(){
    for i in {0..14}
    do
        if [ "${M[i]}" != "$(( $i + 1 ))" ]
        then
            return
        fi
    done
    echo "Вы собрали головоломку за $STEP ходов. Хотите сыграть еще раз [y/n]? "
    while :
    do
        read -n 1 -s
        case $REPLY in
            y|Y)
                init_play
                break
            ;;
            n|N) exit
            ;;
        esac
    done
}


init_play(){
    M=()
    EMPTY=
    STEP=1
    RANDOM=$RANDOM
    for i in {1..15}
    do
        j=$(( RANDOM % 16 ))
        while [[ ${M[j]} != "" ]]
        do
            j=$(( RANDOM % 16 ))
        done
        M[j]=$i
    done
    for i in {0..15}
    do
        [[ ${M[i]} == "" ]] && EMPTY=$i
    done
    paint
}


start_play(){
while :
do
    STEP=$(($STEP+1))
    echo "Ваш ход (q - выход)"
    read INPUT_STRING
    if [[ $INPUT_STRING -eq "q" ]]; then
          quit_play
    fi
    for i in "${!M[@]}"; do
        if [ "${M[$i]}" -eq "$INPUT_STRING" ]; then
          case $((i - EMPTY)) in
            -1)
              MOVE="a"
              ;;
            1)
              MOVE="d"
              ;;
            -4)
              MOVE="w"
              ;;
            4)
              MOVE="s"
              ;;
            *)
              AVAILABLE_MOVS=()
              [ $((EMPTY-1)) -gt -1 ] && AVAILABLE_MOVS+=($((M[EMPTY-1])))
              [ $((EMPTY+1)) -lt 15 ] && AVAILABLE_MOVS+=($((M[EMPTY+1])))
              [ $((EMPTY-4)) -gt -1 ] && AVAILABLE_MOVS+=($((M[EMPTY-4])))
              [ $((EMPTY+4)) -lt 15 ] && AVAILABLE_MOVS+=($((M[EMPTY+4])))
              echo ""
            ;;
          esac
        fi
    done
    case $MOVE in
        s)
            [ $EMPTY -lt 12 ] && swap $(( $EMPTY + 4 ))
        ;;
        d)
            COL=$(( $EMPTY % 4 ))
            [ $COL -lt 3 ] && swap $(( $EMPTY + 1 ))
        ;;
        w)
            [ $EMPTY -gt 3 ] && swap $(( $EMPTY - 4 ))
        ;;
        a)
            COL=$(( $EMPTY % 4 ))
            [ $COL -gt 0 ] && swap $(( $EMPTY - 1 ))
        ;;
    esac
    paint
    validate_win
done
}

init_play
start_play