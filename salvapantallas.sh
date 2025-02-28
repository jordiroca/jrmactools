#!/bin/bash

# Valores por defecto
TIEMPO_SALVAPANTALLAS_MIN_DEFECTO=5

# Función para mostrar la ayuda de uso
uso() {
    echo "Uso: $0 [tiempo_salvapantallas][s|m|h] [tiempo_apagar_pantalla][s|m|h]"
    echo "  - tiempo_salvapantallas: Tiempo antes de que se active el salvapantallas (por defecto: 5m)"
    echo "  - tiempo_apagar_pantalla: Opcional. Si no se especifica, se calcula como:"
    echo "      tiempo_salvapantallas + max(tiempo_salvapantallas, 5m)."
    echo "  - Usa 's' para segundos, 'm' para minutos (por defecto) o 'h' para horas."
    echo "Ejemplos:"
    echo "  $0 10m        # Salvapantallas: 10m, Apagar pantalla: 20m"
    echo "  $0 2m 5m      # Salvapantallas: 2m, Apagar pantalla: 5m"
    echo "  $0 5m 3m      # Salvapantallas: 5m, Apagar pantalla: 3m"
    echo "  $0 2h         # Salvapantallas: 2h, Apagar pantalla: 4h"
    exit 1
}

# Función para convertir tiempo a minutos
convertir_a_minutos() {
    local valor_tiempo=$1
    if [[ "$valor_tiempo" =~ ^([0-9]+)([smh]?)$ ]]; then
        local numero=${BASH_REMATCH[1]}
        local unidad=${BASH_REMATCH[2]:-m}  # Por defecto, minutos si no se especifica unidad
        case "$unidad" in
            s) echo $((numero / 60)) ;;  # Convertir segundos a minutos
            m) echo $numero ;;
            h) echo $((numero * 60)) ;;  # Convertir horas a minutos
            *) echo "Formato de tiempo inválido"; exit 1 ;;
        esac
    else
        echo "Formato de tiempo inválido"; exit 1
    fi
}

# Procesar parámetros
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    uso
fi

if [[ $# -gt 2 ]]; then
    echo "Error: Demasiados argumentos."
    uso
fi

# Convertir primer parámetro (tiempo de salvapantallas)
if [[ -n "$1" ]]; then
    TIEMPO_SALVAPANTALLAS_MIN=$(convertir_a_minutos "$1")
else
    TIEMPO_SALVAPANTALLAS_MIN=$TIEMPO_SALVAPANTALLAS_MIN_DEFECTO
fi

# Calcular el tiempo de bloqueo (max(tiempo_salvapantallas, 5m))
TIEMPO_BLOQUEO=$(( TIEMPO_SALVAPANTALLAS_MIN > 5 ? TIEMPO_SALVAPANTALLAS_MIN : 5 ))

# Convertir segundo parámetro (tiempo de apagado de pantalla) o calcularlo
if [[ -n "$2" ]]; then
    TIEMPO_APAGADO_PANTALLA_MIN=$(convertir_a_minutos "$2")
else
    TIEMPO_APAGADO_PANTALLA_MIN=$((TIEMPO_SALVAPANTALLAS_MIN + TIEMPO_BLOQUEO))
fi

# Convertir minutos a segundos para el salvapantallas
TIEMPO_SALVAPANTALLAS_SEG=$((TIEMPO_SALVAPANTALLAS_MIN * 60))

# Aplicar configuración (se necesita sudo para 'pmset')
defaults -currentHost write com.apple.screensaver idleTime -int $TIEMPO_SALVAPANTALLAS_SEG
sudo pmset -a displaysleep $TIEMPO_APAGADO_PANTALLA_MIN

echo "✔ El salvapantallas se activará tras $TIEMPO_SALVAPANTALLAS_MIN minuto(s) ($TIEMPO_SALVAPANTALLAS_SEG segundos)."
echo "✔ La pantalla se apagará tras $TIEMPO_APAGADO_PANTALLA_MIN minuto(s)."
