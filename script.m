clear all;

% Parámetros iniciales
ti = 0;
fm = 360;  % Frecuencia de muestreo
Tm = 1/fm;

% Cargar la señal
y = load('signals105.txt');

% Obtener el número de muestras
n = size(y, 1);  % número de filas

% Calcular el tiempo final
tf = (n - 1) * Tm;  % Ajustar para que el vector de tiempo coincida con el número de muestras

% Crear el vector de tiempo
t = ti : Tm : tf;

% Separar los canales
canal1 = y(:, 1);  % Primer canal

% Definir los instantes de tiempo de interés
t_inicio = 0;  % Instante de tiempo inicial (en segundos)
t_fin = 200;     % Instante de tiempo final (en segundos)

% Encontrar los índices correspondientes a los instantes de tiempo
indice_inicio = find(t >= t_inicio, 1, 'first');
indice_fin = find(t <= t_fin, 1, 'last');

% Extraer los valores del canal 1 entre los instantes de tiempo especificados
canal1_desdehasta = canal1(indice_inicio:indice_fin);
t_filtrado = t(indice_inicio:indice_fin);

%figure(1);
%plot(t_filtrado, canal1_desdehasta);
n_filtrado = length(canal1_desdehasta);

% FILTRO PASA BANDA--------------------------------------------------------
%-------------------------------------------------------------------------
% Diseño del filtro PASA BAJO
% Frecuencia de corte = 11 Hz
Wn = 11 / (fm / 2);  % Normalizo la frecuencia
[b_pb, a_pb] = butter(2, Wn, 'low');  % Filtro Butterworth de 2º orden

% Diseño del filtro PASA ALTO
% Frecuencia de corte = 0.5 Hz
Wn = 0.5 / (fm / 2);  % Normalizar frecuencia
[b_pa, a_pa] = butter(2, Wn, 'high');  % Filtro Butterworth de 2º orden

% Aplico el filtro pasa bajo
canal1_lp = filter(b_pb, a_pb, canal1_desdehasta);

% Luego aplico el filtro pasa alto
canal1_filtrado = filter(b_pa, a_pa, canal1_lp);



% FILTRO DERIVADOR---------------------------------------------------------
%-------------------------------------------------------------------------
canal1_deriv = zeros(size(canal1_filtrado));

for i = 5:n_filtrado
    canal1_deriv(i) = (1/(8*Tm)) * (2*canal1_filtrado(i) + canal1_filtrado(i-1) - canal1_filtrado(i-3) - 2*canal1_filtrado(i-4));
end

% FILTRO CUADRATICO---------------------------------------------------------
%--------------------------------------------------------------------------
canal1_squared = canal1_deriv.^2;

% FILTRO VENTANA MOVIL INTEGRADORA------------------------------------------
%--------------------------------------------------------------------------
% Definir el tamaño de la ventana
window_size = round(0.150 * fm);  % 150 ms de ventana

% Aplicar el filtro de ventana móvil integradora
canal1_integ = filter(ones(1, window_size)/window_size, 1, canal1_squared);

% Detección de picos QRS---------------------------------------------------
%---------------------------------------------------------------------------
altura_pico_minima = max(canal1_integ) * 0.3; % Umbral inicial para detectar picos
distancia_pico_minima = round(0.1 * fm); % Distancia mínima entre picos (800 ms)

[peaks1, loc1] = findpeaks(canal1_integ, 'MinPeakHeight', altura_pico_minima, 'MinPeakDistance', distancia_pico_minima);

% Graficar la detección de picos
figure;
plot(t_filtrado, canal1_integ);
hold on;
plot(t_filtrado(loc1), peaks1, 'ro');  
title('ECG Canal 1 - Detección de Picos QRS');
xlabel('Tiempo (s)');
ylabel('Amplitud');
hold off;


% Calcular el intervalo RR y la frecuencia cardíaca
RR_intervals1 = diff(loc1) * Tm;  % Intervalo RR en segundos
frec_card1 = 60 ./ RR_intervals1; % Frecuencia cardíaca en bpm

% Identificación de PVCs ---------------------------------------------------
% -------------------------------------------------------------------------
% Detectar PVCs basado en la morfología del QRS y el intervalo RR

% Umbrales para detección de PVCs
QRS_ANCHO_MIN = 0.12 * fm;  % Ancho mínimo del QRS (en muestras)
COEF=0.65* mean(RR_intervals1);
RR_INTERVALO_MIN = COEF * fm;  % Intervalo RR mínimo para considerar un PVC (en muestras)

% Detectar QRS anchos
qrs_ancho = [];
contador_pvc = 0;
for j = 2:length(loc1)
    if (loc1(j) - loc1(j-1)) < RR_INTERVALO_MIN && (loc1(j) - loc1(j-1)) > QRS_ANCHO_MIN
        qrs_ancho = [qrs_ancho, loc1(j)];
        contador_pvc = contador_pvc + 1;
    end
end

% Graficar la detección de picos y PVCs
figure;
plot(t_filtrado, canal1_integ);
hold on;
plot(t_filtrado(loc1), peaks1, 'ro');  % Marcar los picos detectados
plot(t_filtrado(qrs_ancho), canal1_integ(qrs_ancho), 'go');  % Marcar los PVCs detectados
title('Detección de Picos QRS y PVCs');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend('Señal integrada', 'Picos QRS detectados', 'PVCs detectados');
hold off;