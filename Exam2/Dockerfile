FROM php:7.2-apache
RUN curl -LJO https://raw.githubusercontent.com/thachnv92/SysEngHomeTest/master/Exam2/index.php -o /var/www/html/
RUN touch /var/log/request.log
RUN chmod o+w /var/log/request.log
EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
