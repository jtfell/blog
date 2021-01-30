FROM haskell:8.4.3

RUN apt-get update && apt-get install --yes git ssh

RUN stack --resolver lts-12.4 install hakyll

EXPOSE 8000

ENTRYPOINT ["bash"]
