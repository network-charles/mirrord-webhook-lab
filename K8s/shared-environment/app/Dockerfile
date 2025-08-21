FROM python:slim
WORKDIR /app
COPY K8s/shared-environment/app/main.py /app
RUN pip install flask
CMD ["python", "main.py"]
