data = [50	50	97.418
50	60	96.454
50	70	95.484
50	80	92.904
50	90	90.968
50	100	93.55
60	50	97.098
60	60	89.356
60	70	97.098
60	80	94.194
60	90	89.354
60	100	96.13
70	50	97.42
70	60	98.066
70	70	92.58
70	80	95.484
70	90	97.42
70	100	91.936
80	50	87.422
80	60	94.518
80	70	93.226
80	80	91.292
80	90	92.904
80	100	93.55
90	50	86.776
90	60	85.162
90	70	98.066
90	80	96.452
90	90	97.42
90	100	97.42
100	50	97.418
100	60	94.518
100	70	90.646
100	80	95.486
100	90	84.518
100	100	89.678
100	85	98.388
];

figure()
plot3(data(1:36,1),data(1:36,2),data(1:36,3), 'ko',...
    'LineWidth',2,...
    'MarkerFaceColor',[.1 .1 .1],...
    'MarkerSize',3)
grid on
hold on
plot3(data(37, 1),data(37,2),data(37,3), 'pr',...
    'LineWidth',2,...
    'MarkerFaceColor',[1 .6 .6],...
    'MarkerSize',7)
legend('The others', 'Proposed')
%title('The comparison of accuracy by array size')
xlabel('Width')
ylabel('Height')
zlabel('Accuracy (%)')