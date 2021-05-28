import React, { useEffect, useState } from 'react';
import classnames from 'classnames';
import useBaseUrl from '@docusaurus/useBaseUrl';
import Layout from '@theme/Layout';
import styles from './styles.module.css';
import showcaseData from '@site/static/showcase.json';
import Modal from 'react-modal';
import TweetEmbed from 'react-tweet-embed';

function Filter({ expanded: expandedInitial, data, setFilteredData }) {
  const [expanded, setExpanded] = useState(!!expandedInitial);
  const [filter, setFilter] = useState({
    hasCode: { active: false, value: true },
  });
  useEffect(() => {
    const filterFn = (data) =>
      Object.keys(filter).reduce((acc, key) => {
        if (filter[key].active) {
          return acc && filter[key].value === data[key];
        }
        return acc;
      }, true);

    setFilteredData(data.filter(filterFn));
  }, [filter]);

  const resetAllFilters = () => {
    const notFiltered = Object.keys(filter).reduce((acc, key) => {
      acc[key] = false;
      return acc;
    }, {});
    setFilter(notFiltered);
  };

  const updateFilter = (updatedFilters) => {
    setFilter({ ...filter, ...updatedFilters });
  };

  const filterButton = (
    <>
      <button
        className={classnames(
          'button button--secondary button--lg',
          styles.filterButton
        )}
        onClick={() => setExpanded(!expanded)}>
        Filter ↑
      </button>
    </>
  );

  const filterExpanded = (
    <>
      <div className={styles.filter}>
        <article>
          <h2>Source code</h2>
          <button
            className={classnames(
              'button button--lg',
              filter.hasCode.active ? 'button--primary ' : 'button--outline'
            )}
            onClick={() =>
              updateFilter({
                hasCode: { active: !filter.hasCode.active, value: true },
              })
            }>
            Available
          </button>
        </article>
        {/* <button className="button button--primary button--lg margin-horiz--none">
          Show results
        </button> */}
        <button className={styles.resetFilters} onClick={resetAllFilters}>
          Reset filters
        </button>
      </div>
    </>
  );
  return (
    <>
      {filterButton}
      {expanded && filterExpanded}
    </>
  );
}

function Card(props) {
  const {
    data: { title, name, imageUri, link, platform },
    setModalState,
  } = props;

  return (
    <>
      <article className={styles.card}>
        <div
          className={styles.cardImgContainer}
          onClick={() =>
            setModalState({ isOpen: true, selectedData: props.data })
          }>
          <img src={imageUri} className={styles.cardImg} />
        </div>
        <div className={styles.cardDescription}>
          <h2 className={styles.cardTitle}>{title}</h2>
          <p className={classnames(styles.cardAuthor, 'margin--none')}>
            by{' '}
            <a href={link} className={styles.cardTextNick}>
              {name}
            </a>{' '}
            on {platform}
          </p>
        </div>
      </article>
    </>
  );
}

function ShowcaseModal({ modalState, setModalState }) {
  return (
    // remove ariaHideApp
    <Modal
      ariaHideApp={false}
      isOpen={modalState.isOpen}
      onRequestClose={() => setModalState({ ...modalState, isOpen: false })}
      contentLabel="Example Modal"
      style={{
        content: {
          top: '50%',
          left: '50%',
          right: 'auto',
          bottom: 'auto',
          marginRight: '-50%',
          transform: 'translate(-50%, -50%)',
          border: 'none',
          borderRadius: 0,
        },
        overlay: {
          backgroundColor: 'rgba(38, 38, 38, 0.5)',
        },
      }}>
      <div
        style={{
          width: '1200px',
          display: 'flex',
          flexDirection: 'column',
        }}>
        <TweetEmbed id="1197617218575589377" placeholder={'loading'} />
        <h1>{modalState.selectedData?.title}</h1>
        <p className={classnames(styles.cardAuthor, 'margin--none')}>
          by{' '}
          <a
            href={modalState.selectedData?.link}
            className={styles.cardTextNick}>
            {modalState.selectedData?.name}
          </a>{' '}
          on {modalState.selectedData?.platform}
        </p>
      </div>
    </Modal>
  );
}

function Showcase() {
  const [filteredData, setFilteredData] = useState(showcaseData);
  const [modalState, setModalState] = useState({
    isOpen: false,
    selectedData: undefined,
  });
  return (
    <Layout wrapperClassName={styles.layout}>
      <ShowcaseModal modalState={modalState} setModalState={setModalState} />
      <div className={styles.containerWrapper}>
        <div className={styles.container}>
          <Filter
            expanded={false}
            data={showcaseData}
            setFilteredData={setFilteredData}
          />
          <div className={styles.cardsGrid}>
            {filteredData.slice(0, 12 + 1).map((data, i) => (
              <Card key={i} data={data} setModalState={setModalState} />
            ))}
          </div>
        </div>
      </div>
    </Layout>
  );
}
export default Showcase;
