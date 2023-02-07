FROM heates:latest

COPY ./launch_heates.sh /code/launch_heates.sh
RUN chmod 777 /code/launch_heates.sh
WORKDIR /code

# This is the command that will run your model
ENTRYPOINT ["/code/launch_heates.sh"]


