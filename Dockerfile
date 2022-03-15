FROM python:alpine
RUN mkdir /usr/app
COPY . /usr/app/
WORKDIR /usr/app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
