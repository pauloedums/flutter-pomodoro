import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
part 'pomodoro.store.g.dart';

class PomodoroStore = _PomodoroStore with _$PomodoroStore;

enum TipoIntervalo { TRABALHO, DESCANSO }

abstract class _PomodoroStore with Store {
  @observable
  bool iniciado = false;

  @action
  void iniciar() {
    iniciado = true;
    cronometro = Timer.periodic(
      Duration(milliseconds: 50),
      (timer) {
        if (minutos == 0 && segundos == 0) {
          _trocarTipoIntervalor();
        } else if (segundos == 0) {
          segundos = 59;
          minutos--;
        } else {
          segundos--;
        }
      },
    );
  }

  @action
  void parar() {
    iniciado = false;
    cronometro?.cancel();
  }

  @action
  void reiniciar() {
    parar();
    minutos = estarTrabalhando() ? tempoTrabalho : tempoDescanso;
    segundos = 0;
  }

  @observable
  TipoIntervalo tipoIntervalo = TipoIntervalo.TRABALHO;

  Timer? cronometro;

  @observable
  int minutos = 2;

  @observable
  int segundos = 0;

  @observable
  int tempoTrabalho = 2;

  @observable
  int tempoDescanso = 1;

  @action
  void incrementarTempoTrabalho() {
    ++tempoTrabalho;
    if (estarTrabalhando()) {
      reiniciar();
    }
  }

  @action
  void decrementarTempoTrabalho() {
    if (tempoTrabalho > 1) {
      --tempoTrabalho;
      if (estarTrabalhando()) {
        reiniciar();
      }
    }
  }

  @action
  void incrementarTempoDescanso() {
    ++tempoDescanso;
    if (estarDescansando()) {
      reiniciar();
    }
  }

  @action
  void decrementarTempoDescanso() {
    if (tempoDescanso > 1) {
      --tempoDescanso;
      if (estarDescansando()) {
        reiniciar();
      }
    }
  }

  bool estarTrabalhando() {
    return tipoIntervalo == TipoIntervalo.TRABALHO;
  }

  bool estarDescansando() {
    return tipoIntervalo == TipoIntervalo.DESCANSO;
  }

  void _trocarTipoIntervalor() {
    if (estarTrabalhando()) {
      tipoIntervalo = TipoIntervalo.DESCANSO;
      minutos = tempoDescanso;
    } else {
      tipoIntervalo = TipoIntervalo.TRABALHO;
      minutos = tempoTrabalho;
    }
    segundos = 0;
  }
}
