clc; clear;

% 2017년 혼잡도 데이터
RawTable = readtable('서울교통공사_혼잡도(2017).csv', 'PreserveVariableNames', true);
congAll2017 = double(table2array(RawTable(:,5:end))); % 역x시간대 혼잡도
stationCongAverage2017 = mean(congAll2017, 2); % 역별 혼잡도 평균 벡터
timeCongAverage2017 = mean(congAll2017, 1); % 시간대별 혼잡도 평균 벡터

timeLineLength = size(congAll2017,2); % 시간대 개수
timeLine = zeros(1, timeLineLength); % 시간대 5:30~24:30
tempTime = 5; % 5시 30에서 시작
for i=1:timeLineLength
    tempTime = tempTime + 0.5;
    timeLine(1,i) = tempTime;
end

% 승하차인원 데이터(요일별 평균) : 월 화 수 목 금 토 일 전체
tic;
Transit1 = xlsread('TransitSWPass_1.xlsx'); Transit1 = Transit1(3:end,:); toc; tic;
Transit2 = xlsread('TransitSWPass_2.xlsx'); Transit2 = Transit2(3:end,:); toc; tic;
Transit3 = xlsread('TransitSWPass_3.xlsx'); Transit3 = Transit3(3:end,:); toc; tic;
Transit4 = xlsread('TransitSWPass_4.xlsx'); Transit4 = Transit4(3:end,:); toc; tic;
Transit5 = xlsread('TransitSWPass_5.xlsx'); Transit5 = Transit5(3:end,:); toc; tic;
Transit6 = xlsread('TransitSWPass_6.xlsx'); Transit6 = Transit6(3:end,:); toc; tic;
Transit7 = xlsread('TransitSWPass_7.xlsx'); Transit7 = Transit7(3:end,:); toc; tic;
Transit8 = xlsread('TransitSWPass_8.xlsx'); Transit8 = Transit8(3:end,:); toc; tic;
toc;


%% 0. 혼잡도 플롯

figure(1);
plot(timeLine, timeCongAverage2017, '-o','MarkerIndices', 2:2:length(timeLine));
xticks(0:1:39);
title("시간대별 평균 혼잡도");

%figure(2);
%stations = table2cell(RawTable(:,3));
%histogram(stationCongAverage2017);
%title("역별 평균 혼잡도");
%xticks(0:1:size(stations, 1));
%xticklabels(stations);


%% 1. 혼잡도 데이터로 가장 혼잡한 역과 시간대 분석

[val, idx] = max(stationCongAverage2017); %평균적으로 가장 혼잡한 역
answer = table2cell(RawTable(uint8(idx),3));
fprintf('평균적으로 가장 혼잡한 역은 %s, 평균 혼잡도는 %.0f \n', answer{:}, val);

[val2, idx2] = max(timeCongAverage2017); %평균적으로 가장 혼잡한 시간대
answer2 = timeLine(uint8(idx2));
fprintf('하루 중 가장 혼잡한 시간은 %.0f시, 이때 혼잡도는 %.0f \n', answer2, val2);

val3 = max(max(congAll2017));
[val3_x,val3_y] = find(congAll2017==val3);
answer3_1 = table2cell(RawTable(uint8(val3_x),3));
answer3_2 = timeLine(uint8(val3_y));
fprintf('일시적으로 가장 혼잡한 역은 %.0f시의 %s역, 이때 혼잡도는 %.0f \n', answer3_2, answer3_1{:}, val3);

% 평균적으로 가장 혼잡한 지하철은 교대역으로 평균 혼잡도가 64였다.
% 하루 중 가장 혼잡한 시간대는 출근시간인 8시로 이 시각 모든 역의 평균 혼잡도는 59이다. 퇴근시간 중 피크는 6시 반으로 나타난다.
% 일시적으로 가장 혼잡도가 높았던 역은 8시의 사당역이었다.


%% 2. 승하차인원 시계열의 추세 및 계절성

monthlyAverage = zeros(5, 84);
Transit = Transit1; % 보고싶은 호선 데이터 넣어주기
% size(Transit1, 1) %360
% size(Transit1, 2) %41

yearLineLength = size(monthlyAverage,2) * 5; %  7(요일평균) X 12(월) X 5(년)
yearLine = zeros(1, yearLineLength); % 총 420개
tempYear = 14; % 2014년도에서 시작
for i=1:yearLineLength
    yearLine(1,i) = tempYear;
    tempYear = tempYear + (1/84);
end
yearLine = yearLine';

numOfStation = size(Transit, 1) / 3 / 12;
monthCount = zeros(1,12);
dataByStation = zeros(numOfStation, yearLineLength);
for i=1:size(Transit, 1)
    for j=2:size(Transit, 2)
        curYear = fix((j-1)/8);
        curdayInWeek = rem(j-1, 8);
        curMonth = Transit(i, 1);
        %fprintf('i는 %.0f,j는 %.0f, %.0f %.0f %.0f에 %.0f \n', i, j, curYear, curdayInWeek, curMonth, Transit(i,j));
        if curdayInWeek ~= 0 && rem(i,3) ~= 0
            dataByStation(rem(fix(i/3), 10)+1, (curYear)*84 + (curMonth-1)*7 + curdayInWeek) = Transit(i,j);
        end
    end
    monthCount(1,curMonth) = monthCount(1,curMonth) + 1;
end
yearlyAverage = mean(dataByStation);

figure(3);
plot(yearLine, log(yearlyAverage));
title("로그를 취한 승하차인원 시계열");
% 이 시계열은 모든 날짜의 데이터가 담겨 있는 것이 아니고, 2014년부터 2018년까지 각 달의 요일별 평균 승하차인원을 쭉 나열해 둔 것이다.
% [2014년 1월 월요일, 2014년 1월 화요일, 2014년 1월 수요일 ... 2014년 2월 월요일, 2014년 2월 화요일 ... 2018년 12월 일요일]
% 일별 데이터가 없었기 때문에 요일별 평균 승하차인원 데이터를 사용하게 되었다.
% 완벽한 시계열이라고 볼 수는 없지만 어느 정도의 추세를 파악하는 것은 가능할 것이라고 생각하였다.
% 12주 이동평균을 적용하여 시계열의 성분을 분해해보았다 (7일치 데이터가 12달 단위로 반복되므로)

No = yearLine;
LnC = log(yearlyAverage)';
no = size(No,1);
iterNum = 12;

LnTC = zeros(no-(iterNum-1),1);

for i=1:no-(iterNum-1)
    LnTC(i,1) = mean(LnC(i:i+(iterNum-1),1));
end

% HP filter를 이용한 추세 및 주기 성분 분해
lambda = iterNum^2*100;
[T,C] = hpfilter(LnTC,lambda);

figure(4);
plot(No((iterNum/2):end-(iterNum/2),1),T);
title('로그를 취한 지하철 승하차인원 Trend Component');

TCS = zeros(no-(iterNum-1),3);
TCS(:,1) = T;
TCS(:,2) = C;
TCS(:,3) = LnC((iterNum/2):end-(iterNum/2),1)-LnTC;


%% 3. 주어진 역에 대하여 예상 혼잡도를 도출하기
% 설명변수 : 년 월 요일
% 종속변수 : 승하차인원

searchStation = "신설동";
searchHosun = 1;

% 혼잡도에서 검색
[resultStation,~] = find(table2cell(RawTable(:,3))==searchStation);
[resultHosun,~] = find(table2array(RawTable(:,1))==searchHosun);
resultIdx = intersect(resultStation, resultHosun); %검색역 및 호선과 일치하는 인덱스
resultIdx = resultIdx(1,:); %상선으로 검색

% 승하차인원에서 검색
excelString = 'TransitSWPass_'+string(searchHosun)+'.xlsx';
RawTrans = readtable(excelString, 'PreserveVariableNames', true);
[resultStation2,~] = find(table2cell(RawTrans(:,2)) == searchStation);
resultIdx2 = resultStation2(3,:)/3;

searchIdx = resultIdx2; %dataByStation의 searchIdx번째 데이터를 회귀분석하기
singleLine = dataByStation(searchIdx,:);

resultBox = zeros(size(singleLine,2),4); %년도, 월, 요일, 결과
for i=1:size(singleLine,2)
    resultBox(i,1) = 2014 + fix(i/84);
    resultBox(i,2) = rem(fix(i/7),7)+1;
    resultBox(i,3) = rem(i,7);
    if rem(i,7)==0
        resultBox(i,2) = resultBox(i,2)-1;
        resultBox(i,3) = 7;
    end
    resultBox(i,4) = singleLine(1,i);
end

y = log(resultBox(:,4)); %종속변수 승하차인원
no = size(y, 1); % 행(Observation)의 개수

iota = ones(no,1); % 상수항

X = resultBox(:,1:3); % 설명변수들

b = (inv(X'*X))*X'*y; %X'*X\X'*y % 파라미터 추정. OLS Estimator. 베타
r = y - X*b; % 잔차
s2 = r'*r/(no-size(X,2)); % 시그마 추정. 잔차의 분산
var_b = (inv(X'*X))*s2; % 베타의 분산
se_b = sqrt(diag(var_b)); % 베타의 표준편차

TSS = (y-mean(y))'*(y-mean(y));
RSS = r'*r;

R2 = 1 - RSS/TSS;

avCon = mean(congAll2017(resultIdx,:)); % 검색역의 2017 평균혼잡도
searchYear = 2020;
searchMonth = 5;
searchDayInWeek = 5;
guessCon = avCon * (1+b(1,1))^(searchYear-2017) * (1+b(2,1))^(searchMonth) * (1+b(3,1))^searchDayInWeek;

%2017년 혼잡도 X 
fprintf('%0.f년 %0.f월 %0.f번째요일 %s역의 혼잡도 추정치는 %.0f\n', searchYear, searchMonth, searchDayInWeek, searchStation, guessCon);