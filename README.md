# BigDataGrapes - GaCoVi

Install Docker from https://docs.docker.com/get-docker/

Download or clone the project:

```bash
git clone https://github.com/BigDataGrapes-EU/d5.3-gacovi.git
```

Navigate to the cloned/downloaded folder:

```bash
cd d5.3-ahmose
```

Build the image:

```bash
docker build -t d5.3-gacovi .
```

Run the image as a container:

```bash
docker run -dit --name d5.3-gacovi -p 8000:80  d5.3-gacovi
```

Open your web browser and go to http://localhost:8000 to see the app running.
