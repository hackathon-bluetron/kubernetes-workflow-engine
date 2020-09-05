FROM python:3.7-alpine

LABEL maintainer="Sneha Mallav"

workdir /

RUN apk add bash && \
    pip install xlrd && \
    pip install argparse 

COPY workbook_csv_data_processor.py .

ENTRYPOINT ["/bin/bash"]
CMD ["tail", "-f", "/dev/null"]
