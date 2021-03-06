#!/usr/bin/env bash

MODELS=models
BERT_BASE_DIR=$MODELS/uncased_L-12_H-768_A-12
GLUE_DIR=glue_data
TRAINED_SCORER=sts_output
STS_URL="https://firebasestorage.googleapis.com/v0/b/mtl-sentence-representations.appspot.com/o/data%2FSTS-B.zip?alt=media&token=bddb94a7-8706-4e0d-a694-1109e12273b5"
MODEL_URL="https://storage.googleapis.com/bert_models/2018_10_18/uncased_L-12_H-768_A-12.zip"

# get data
if [ ! -d $GLUE_DIR ]; then
    STS_ZIP=$GLUE_DIR/sts.zip
    mkdir $GLUE_DIR
    curl -o $STS_ZIP $STS_URL
    unzip $STS_ZIP -d $GLUE_DIR
    rm $STS_ZIP
fi

# get weights
if [ ! -d $MODELS ]; then
    mkdir $MODELS
    curl -o ${BERT_BASE_DIR}.zip $MODEL_URL
    unzip ${BERT_BASE_DIR}.zip -d $MODELS
#    rm ${BERT_BASE_DIR}.zip
fi


# fine-tune for STS-B dataset
python run_scorer.py \
  --task_name=STS \
  --do_train=true \
  --do_eval=true \
  --data_dir=$GLUE_DIR/STS-B \
  --vocab_file=$BERT_BASE_DIR/vocab.txt \
  --bert_config_file=$BERT_BASE_DIR/bert_config.json \
  --init_checkpoint=$BERT_BASE_DIR/bert_model.ckpt \
  --max_seq_length=128 \
  --train_batch_size=32 \
  --learning_rate=2e-5 \
  --num_train_epochs=3.0 \
  --output_dir=$TRAINED_SCORER


