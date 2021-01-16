#My idea to monitor response time of a web application

1. Install Nginx to monitor response time of web application
2. Set web application behind an Nginx frontend proxy
3. Configure logging format with time variable
  $request_time – Full request time, starting when NGINX reads the first byte from the client and ending when NGINX sends the last byte of the response body
  $upstream_connect_time – Time spent establishing a connection with an upstream server
  $upstream_header_time – Time between establishing a connection to an upstream server and receiving the first byte of the response header
  $upstream_response_time – Time between establishing a connection to an upstream server and receiving the last byte of the response body
4. Install Filebeat, Elasticsearch, Kibana/Grafana
5. Configure Filebeat push Nginx access log to Elasticsearch.
Then, show response time of web application to Kibana/Grafana Dashboard.
===

Draw a model that is scalable and responsive to the most traffic you have ever deployed
![alt text](https://github.com/thachnv92/SysEngHomeTest/blob/master/Exam3/model.png?raw=true)
