local k = import 'kubernetes.libsonnet';

[
  k.ns('mqtt'),
  k.deployment('mosquitto', [
    { image: 'eclipse-mosquitto:latest' } 
    + k.container.ports([1883, 9001]),
  ], namespace='mqtt'),
]
