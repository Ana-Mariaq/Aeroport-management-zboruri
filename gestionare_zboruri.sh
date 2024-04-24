#!/bin/bash

   clear
   sleep 2
   echo "Bun venit! Aceasta este baza de date a zborurilor de la Aeroportul Baneasa!"
   sleep 4
# Numele fisierului CSV
csv_file="zboruri.csv"

# Separatorul CSV
separator=","

# Functie pentru afisarea zborurilor
 afisare_zboruri() {
    clear
    awk -F"$separator" 'BEGIN {
        printf "%-8s %-12s %-10s %-6s %-16s\n", "ID", "Destinatie", "Companie", "Durata(ore)", "LocuriDisponibile"
        printf "%-8s %-12s %-10s %-6s %-16s\n", "---", "----------", "--------", "-----------", "-----------------"
    }
    NR>1 {
        printf "%-8s %-12s %-10s %-6s %-16s\n", $1, $2, $3, $4, $5
    }' "$csv_file" | column -t
     sleep 2
    read -p "Apasati Enter pentru a continua..."
}

# Functie pentru afisare destinatii si durate
afisare_destinatii_durate() {
    clear
    valid_input=false

    while [ "$valid_input" = false ]
    do
        sleep 1
        read -p "Introduceti numele companiei de la care doriti sa afisam destinatiile si duratele zborurilor: " companie
        if [[ "$companie" =~ [0-9] ]]; then
         sleep 1
         echo "Eroare: Numele companiei nu poate contine caractere numerice."
         sleep 2
        else
            found=false

            while IFS= read -r line
            do
                line_companie=$(echo "$line" | cut -d"," -f3)

                if [ "$line_companie" = "$companie" ]; then
                    found=true
                    break
                fi
            done < "$csv_file"
            if [ "$found" = true ]; then
                valid_input=true
            else
                sleep 1
                echo "Eroare: Compania nu exista in baza de date."
                sleep 2
            fi
        fi
    done
    clear
    sleep 1
    printf "%-12s %-6s\n" "Destinatie" "Durata(ore)"
    printf "%-12s %-6s\n" "----------" "-----------"
    awk -F"$separator" -v comp="$companie" 'NR>1 && $3==comp { printf "%-12s %-6s\n", $2, $4 }' "$csv_file"
    sleep 2
    read -p "Apasati Enter pentru a continua..."
}

# Numele fisierului CSV
csv_file="zboruri.csv"

# Functie pentru adaugarea unui zbor nou
adaugare_zbor() {
    clear
    valid_input=false

    while [ "$valid_input" = false ]
    do
        read -p "Introduceti destinatia: " destinatie

        if [[ "$destinatie" =~ [0-9] ]]; then
            sleep 1
            echo "Eroare: Destinatia nu poate contine caractere numerice."
            sleep 2
        else
            valid_input=true
        fi
    done

    valid_input=false

   while [ "$valid_input" = false ]
    do
        read -p "Introduceti durata: " durata

        if [[ ! "$durata" =~ ^[0-9]+$ ]]; then
            sleep 1
            echo "Eroare: Durata trebuie sa fie o valoare numerica."
            sleep 2
        else
            valid_input=true
        fi
    done

    valid_input=false

    while [ "$valid_input" = false ]
    do
        read -p "Introduceti numele companiei: " companie

        if [[ "$companie" =~ [0-9] ]]; then
            sleep 1
            echo "Eroare: Numele companiei nu poate contine caractere numerice."
            sleep 2
        else
            found=false

            while IFS= read -r line
            do
                line_companie=$(echo "$line" | cut -d"," -f3)

                if [ "$line_companie" = "$companie" ]; then
                    found=true
                    break
                fi
            done < "$csv_file"

            if [ "$found" = false ]; then
                sleep 1
                echo "Eroare: Compania nu exista in baza de date."
                sleep 2
                continue
            fi

            valid_input=true
        fi
  done

    valid_input=false

    while [ "$valid_input" = false ]
    do
        read -p "Introduceti numarul de locuri disponibile: " locuri

        if [[ ! "$locuri" =~ ^[0-9]+$ ]]; then
            sleep 1
            echo "Eroare: Numarul de locuri disponibile trebuie sa fie o valoare numerica."
            sleep 2
        else
            valid_input=true
        fi
    done

    # Generare ID
    new_id=$(generate_new_id)

    # Adaugare inregistrare in fisierul CSV
    echo "$new_id,$destinatie,$companie,$durata,$locuri" >> "$csv_file"

    sleep 1
    echo "Zborul cu ID-ul $new_id a fost adaugat cu succes!"
    sleep 2

    read -p "Apasati Enter pentru a continua..."
}

# Functie care genereaza un ID nou bazat pe ultimul ID din fisierul CSV
generate_new_id() {
    local last_id=$(tail -n 1 "$csv_file" | cut -d ',' -f 1)
    local new_id

    if [ -s "$csv_file" ]; then
        new_id=$((last_id + 1))
    else
        new_id=1
    fi

    echo "$new_id"
}
#Functie pentru actualizare inregistrare
actualizare_inregistrare() {
   clear

    while true; do
        read -p "Introduceti ID-ul zborului pe care doriti sa il actualizati: " id

        if [[ ! $id =~ ^[0-9]+$ ]]; then
            sleep 1
            echo "Eroare: ID-ul trebuie sa fie o valoare numerica."
            sleep 2
        else
            found=false
            while IFS= read -r line; do
                line_id=$(echo "$line" | cut -d"," -f1)
                if [ "$line_id" = "$id" ]; then
                    found=true
                    break
                fi
            done < "$csv_file"

            if [ "$found" = true ]; then
                valid_input=false
                while [ "$valid_input" = false ]; do
                    read -p "Introduceti noul numar de locuri disponibile: " locuri

                    if [[ ! $locuri =~ ^[0-9]+$ ]]; then
                        sleep 1
                        echo "Eroare: Numarul de locuri disponibile trebuie sa fie o valoare numerica."
                        sleep 2
                    else
                        valid_input=true
                    fi
                done

                valid_input=false
                while [ "$valid_input" = false ]; do
                    read -p "Introduceti noua durata a zborului: " durata

                    if [[ ! $durata =~ ^[0-9]+$ ]]; then
                        sleep 1
                        echo "Eroare: Durata zborului trebuie sa fie o valoare numerica."
                        sleep 2
                    else
                        valid_input=true
                    fi
                done
                awk -v id="$id" -v durata="$durata" -v locuri="$locuri" 'BEGIN {FS=OFS=","} $1 == id {$5=durata; $6=locuri} 1' "$csv_file" > tmpfile && mv tmpfile "$csv_file"

                sleep 1
                echo "Zborul cu ID-ul $id a fost actualizat cu succes!"
                sleep 2
                break
            else
                sleep 1
                echo "Eroare: Zborul cu ID-ul $id nu exista in baza de date."
                sleep 2
            fi
        fi
    done
    read -p "Apasati Enter pentru a continua..."
}
# Functie pentru stergerea unei inregistrari pe baza ID-ului
stergere_zbor() {
    clear
    while true
    do
        read -p "Introduceti ID-ul zborului pe care doriti sa il anulati: " id

        if [[ ! "$id" =~ ^[0-9]+$ ]]; then
            sleep 1
            echo "Eroare: ID-ul trebuie sa fie o valoare numerica."
            sleep 2
        else
            found=false

            while IFS= read -r line
            do
                line_id=$(echo "$line" | cut -d"," -f1)

                if [ "$line_id" = "$id" ]; then
                    found=true
                    break
                fi
            done < "$csv_file"

            if [ "$found" = true ]; then
                grep -v "^$id," "$csv_file" > tmp_file && mv tmp_file "$csv_file"
                sleep 1
                echo "Zborul cu ID-ul $id a fost anulat cu succes!"
                sleep 2
                break
            else
                sleep 1
                echo "Eroare: Zborul cu ID-ul $id nu exista in baza de date."
                sleep 2
            fi
        fi
    done

    read -p "Apasati Enter pentru a continua..."

}

# Meniul principal
while true
do
    clear
    sleep 1
    echo "Ce doriti sa faceti?"
    sleep 1
    echo "----------------------------"
    echo "1. Afiseaza toate zborurile"
    echo "2. Afiseaza destinatii si durate zboruri"
    echo "3. Adauga un zbor nou"
    echo "4. Modifica un zbor inregistrat"
    echo "5. Anuleaza un zbor"
    echo "0. Iesire"
    echo "----------------------------"
    sleep 2
    read -p "Alegeti o optiune: " optiune
    sleep 1
    case $optiune in
        1) afisare_zboruri ;;
        2) afisare_destinatii_durate ;;
        3) adaugare_zbor ;;
        4) actualizare_inregistrare ;;
        5) stergere_zbor ;;
        0) echo "Ati ales sa iesiti. La revedere!"
           sleep 1
           exit ;;
        *) echo "Optiune invalida" ;;
    esac
done
